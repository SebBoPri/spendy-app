// Vercel Serverless Function to handle receipt analysis
// This keeps your API key secure on the server side

// Attempt to repair common JSON syntax errors
function repairJSON(jsonString) {
  let repaired = jsonString;

  // Remove trailing commas before closing braces/brackets
  repaired = repaired.replace(/,(\s*[}\]])/g, '$1');

  // Remove any trailing text after the last closing brace
  const lastBrace = repaired.lastIndexOf('}');
  if (lastBrace !== -1 && lastBrace < repaired.length - 1) {
    // Check if there's any non-whitespace after the last brace
    const afterBrace = repaired.substring(lastBrace + 1).trim();
    if (afterBrace && !afterBrace.startsWith('}') && !afterBrace.startsWith(']')) {
      console.log('Removing trailing text after JSON:', afterBrace.substring(0, 50));
      repaired = repaired.substring(0, lastBrace + 1);
    }
  }

  // Try to find and complete incomplete JSON
  // Count opening and closing braces
  const openBraces = (repaired.match(/\{/g) || []).length;
  const closeBraces = (repaired.match(/\}/g) || []).length;
  const openBrackets = (repaired.match(/\[/g) || []).length;
  const closeBrackets = (repaired.match(/\]/g) || []).length;

  console.log(`JSON structure: {${openBraces}/${closeBraces}, [${openBrackets}/${closeBrackets}]`);

  // Add missing closing brackets first (they come before braces in nested structures)
  if (openBrackets > closeBrackets) {
    const missing = openBrackets - closeBrackets;
    console.log(`Adding ${missing} missing closing bracket(s)`);
    repaired += '\n' + ']'.repeat(missing);
  }

  // Add missing closing braces
  if (openBraces > closeBraces) {
    const missing = openBraces - closeBraces;
    console.log(`Adding ${missing} missing closing brace(s)`);
    repaired += '\n' + '}'.repeat(missing);
  }

  return repaired;
}

// Transform new enhanced structure to format that works with existing code
function transformReceiptData(receiptData) {
  // Handle both new and old format
  const metadata = receiptData.receipt_metadata || {};
  const financial = receiptData.financial || {};
  const items = receiptData.items || [];

  // Create backwards-compatible structure while preserving rich metadata
  return {
    // Old format (for existing UI compatibility)
    store: metadata.store_name || null,
    date: metadata.date || null,
    time: metadata.time || null,
    total: financial.total || 0,
    items: items.map(item => ({
      name: item.name,
      price: item.total_price || 0,
      category: item.category || 'Other',
      subcategory: item.subcategory || null
    })),

    // New rich metadata (preserved for future features)
    _metadata: {
      store_name: metadata.store_name,
      store_chain: metadata.store_chain,
      store_location: metadata.store_location || {},
      receipt_number: metadata.receipt_number,
      purchase_date: metadata.date,
      purchase_time: metadata.time,
      currency: metadata.currency || 'SEK'
    },

    // Rich item data
    _items_detailed: items.map((item, index) => ({
      line_number: item.line_number || index + 1,
      raw_text: item.raw_text,
      name: item.name,
      brand: item.brand,
      product_type: item.product_type,
      quantity: item.quantity || 1,
      unit_price: item.unit_price || item.total_price || 0,
      total_price: item.total_price || 0,
      discount: item.discount || 0,
      original_price: item.original_price || item.total_price || 0,
      category: item.category || 'Other',
      subcategory: item.subcategory,
      sub_subcategory: item.sub_subcategory,
      tags: item.tags || [],
      unit_of_measure: item.unit_of_measure,
      package_size: item.package_size,
      is_on_sale: item.is_on_sale || false,
      return_eligible: item.return_eligible !== false
    })),

    // Financial details
    _financial: {
      subtotal: financial.subtotal || 0,
      total_discounts: financial.total_discounts || 0,
      total: financial.total || 0,
      amount_paid: financial.amount_paid || 0,
      change: financial.change || 0,
      loyalty_points_earned: financial.loyalty_points_earned || 0,
      loyalty_points_used: financial.loyalty_points_used || 0
    },

    // Special notes
    _special_notes: receiptData.special_notes || {},

    // Analytics
    _analytics: receiptData.analytics || {}
  };
}

// Validate receipt data
function validateReceipt(receiptData) {
  const errors = [];
  const warnings = [];

  // Check if items exist
  if (!receiptData.items || receiptData.items.length === 0) {
    errors.push({
      type: 'no_items',
      message: 'No items found on receipt'
    });
    return { isValid: false, errors, warnings };
  }

  // Check if prices sum to total
  const itemsSum = receiptData.items.reduce((sum, item) => sum + (item.price || 0), 0);
  const total = receiptData.total || 0;

  if (Math.abs(itemsSum - total) > 2) {
    warnings.push({
      type: 'sum_mismatch',
      message: `Items sum (${itemsSum.toFixed(2)} kr) doesn't match total (${total.toFixed(2)} kr)`,
      difference: Math.abs(itemsSum - total).toFixed(2)
    });
  }

  // Check for uncategorized items
  const uncategorizedItems = receiptData.items.filter(item =>
    !item.category || item.category === 'Other'
  );

  if (uncategorizedItems.length > receiptData.items.length * 0.3) {
    warnings.push({
      type: 'many_uncategorized',
      message: `${uncategorizedItems.length} items could not be categorized`,
      items: uncategorizedItems.map(i => i.name)
    });
  }

  // Check for missing metadata
  if (!receiptData.store || receiptData.store === null) {
    warnings.push({
      type: 'missing_store',
      message: 'Store name not found on receipt'
    });
  }

  if (!receiptData.date || receiptData.date === null) {
    warnings.push({
      type: 'missing_date',
      message: 'Receipt date not found'
    });
  }

  return {
    isValid: errors.length === 0,
    errors,
    warnings,
    itemsSum: itemsSum.toFixed(2),
    total: total.toFixed(2),
    categorized: receiptData.items.length - uncategorizedItems.length,
    uncategorized: uncategorizedItems.length
  };
}

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Enable CORS (Allows your website to talk to this script)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight request
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  try {
    const { imageData } = req.body;

    if (!imageData) {
      return res.status(400).json({ error: 'No image data provided' });
    }

    // Get API key from environment variable (secure!)
    const apiKey = process.env.ANTHROPIC_API_KEY;
    
    if (!apiKey) {
      console.error('ANTHROPIC_API_KEY not set in environment variables');
      return res.status(500).json({ error: 'API key not configured' });
    }

    // Extract base64 data and media type
    const base64Data = imageData.split(',')[1];
    let mediaType = 'image/jpeg';
    if (imageData.startsWith('data:image/png')) mediaType = 'image/png';
    else if (imageData.startsWith('data:image/webp')) mediaType = 'image/webp';

    // Call Claude API
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        // Updated to the current January 2026 model
        model: 'claude-sonnet-4-5-20250929',
        max_tokens: 4000,
        messages: [{
          role: 'user',
          content: [
            {
              type: 'image',
              source: {
                type: 'base64',
                media_type: mediaType,
                data: base64Data
              }
            },
            {
              type: 'text',
              text: `You are an expert receipt analysis AI. Extract ALL possible information from this receipt with maximum detail.

CRITICAL RULES:
1. Return ONLY valid JSON, no markdown, no explanations, no trailing text
2. Extract EVERY line item visible on receipt
3. Use null for missing data, never guess
4. All prices in SEK (Swedish Krona)
5. Preserve exact product names as written - escape any quotes or special characters properly
6. Calculate totals precisely
7. MUST be valid, parseable JSON - no syntax errors, no trailing commas
8. Escape special characters: use \\" for quotes inside strings, avoid control characters

REQUIRED DATA STRUCTURE:
{
  "receipt_metadata": {
    "store_name": "exact store name from receipt",
    "store_chain": "parent company (e.g., 'ICA' from 'ICA Maxi')",
    "store_location": {
      "address": "street address if visible",
      "city": "city name",
      "postal_code": "postal code if visible"
    },
    "receipt_number": "receipt/transaction number",
    "date": "YYYY-MM-DD",
    "time": "HH:MM:SS (24h format)",
    "currency": "SEK"
  },

  "items": [
    {
      "line_number": 1,
      "raw_text": "exact text from receipt line",
      "name": "cleaned product name",
      "brand": "brand name if identifiable",
      "product_type": "general product type (e.g., Milk, Bread, Shampoo)",
      "quantity": 1.0,
      "unit_price": 0.00,
      "total_price": 0.00,
      "discount": 0.00,
      "original_price": 0.00,
      "category": "primary category",
      "subcategory": "secondary category",
      "sub_subcategory": "tertiary category if applicable",
      "tags": ["organic", "swedish", "discount", "member_price"],
      "unit_of_measure": "kg/L/pcs/etc",
      "package_size": "size with unit (e.g., 1L, 500g)",
      "is_on_sale": false,
      "return_eligible": true
    }
  ],

  "financial": {
    "subtotal": 0.00,
    "total_discounts": 0.00,
    "total": 0.00,
    "amount_paid": 0.00,
    "change": 0.00,
    "loyalty_points_earned": 0,
    "loyalty_points_used": 0
  },

  "special_notes": {
    "promotions": ["2 for 1 on milk", "member discount applied"],
    "coupons_used": [],
    "return_policy": "visible return policy text",
    "loyalty_card_number": "masked card number (last 4 digits only)",
    "campaign_codes": []
  },

  "analytics": {
    "items_count": 15,
    "time_of_day": "morning/afternoon/evening/night",
    "day_of_week": "Monday/Tuesday/etc"
  }
}

CATEGORIZATION GUIDE:
- Groceries: Food, beverages, produce, meat, dairy, bakery, snacks
  - Subcategories: Produce, Dairy, Meat, Bakery, Beverages, Snacks, Frozen, Pantry, Condiments
  - Sub-subcategories: For Dairy: Milk, Cheese, Yogurt, Butter, Cream
- Household: Cleaning supplies, paper products, kitchen items, storage
  - Subcategories: Cleaning, Paper Products, Kitchen, Laundry, Storage
- Personal Care: Hygiene, cosmetics, health
  - Subcategories: Hygiene, Cosmetics, Hair Care, Oral Care, Medicine
- Electronics: Tech products, batteries, accessories
- Clothing: Apparel, shoes, accessories
- Dining: Restaurant meals, takeout, coffee shops
- Transportation: Gas, parking, public transit, tolls
- Entertainment: Movies, games, books, hobbies
- Health: Pharmacy, medical, supplements
- Pets: Pet food, supplies, vet
- Other: Anything not fitting above

BRAND EXTRACTION:
Common Swedish brands to recognize:
- Groceries: Arla, Scan, Findus, Felix, Estrella, Eldorado, Garant, Valio, Skånemejerier
- Household: Zalo, Yes, Neutral, Ajax, Glorix
- Personal Care: L'Oréal, Dove, Nivea, ACO, Apotek
If brand not recognizable, use null.

TAGS TO ADD:
- "organic" - if product is labeled organic/ekologisk
- "swedish" - if product is Swedish made
- "discount" - if item shows a discount
- "member_price" - if special member pricing
- "perishable" - for items with short shelf life
- "frozen" - for frozen items
- "imported" - if clearly imported
- "sale" - if part of a sale/campaign

PRICE CALCULATIONS:
- Unit price = total_price / quantity
- If discount shown: original_price = total_price + discount
- price_per_unit = unit_price + "/" + unit_of_measure

QUALITY CHECKS:
1. Sum of all item prices should match receipt subtotal
2. Subtotal - discounts = Total (allow ±1 kr rounding)
3. Every visible line item must be extracted
4. Preserve original spelling/language

TIME OF DAY:
- morning: 05:00-11:59
- afternoon: 12:00-16:59
- evening: 17:00-20:59
- night: 21:00-04:59

FINAL VALIDATION BEFORE RESPONDING:
1. Verify your JSON is complete and well-formed
2. Check all braces and brackets are properly closed
3. Remove any trailing commas
4. Ensure all strings are properly quoted and escaped
5. Verify the JSON can be parsed without errors

Return ONLY the JSON object, nothing else:`
            }
          ]
        }]
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Claude API error:', response.status, errorText);
      return res.status(response.status).json({ 
        error: `API Error: ${response.status}`,
        details: errorText 
      });
    }

    const data = await response.json();

    // Extract text from response
    const textContent = data.content.find(c => c.type === 'text')?.text || '';

    if (!textContent) {
      console.error('No text content in AI response:', JSON.stringify(data, null, 2));
      return res.status(500).json({
        error: 'Receipt analysis failed',
        message: 'The AI did not return any text content. This might be a temporary issue. Please try again.',
        details: 'No text content in response'
      });
    }

    console.log('AI Response length:', textContent.length);
    console.log('AI Response preview:', textContent.substring(0, 200));

    // Clean up JSON (removes markdown formatting if AI adds it)
    let cleanedText = textContent.trim();

    // Remove markdown code blocks with multiple strategies
    cleanedText = cleanedText
      .replace(/```json\s*/gi, '')
      .replace(/```\s*/g, '')
      .replace(/^json\s*/gi, '');

    // Try to extract JSON object with greedy matching
    const jsonMatch = cleanedText.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      cleanedText = jsonMatch[0];
    } else {
      console.error('No JSON object found in response');
      console.error('Full response:', textContent);
      return res.status(500).json({
        error: 'Receipt format not recognized',
        message: 'Could not find receipt data in the image. Please ensure the image shows a clear receipt with visible text.',
        details: 'No JSON structure found',
        preview: textContent.substring(0, 300)
      });
    }

    // Parse the data
    let receiptData;
    try {
      receiptData = JSON.parse(cleanedText);
    } catch (parseError) {
      console.error('JSON parse error (first attempt):', parseError.message);
      console.error('Parse error at position:', parseError.message.match(/position (\d+)/)?.[1]);

      // Try to repair the JSON and parse again
      console.log('Attempting to repair JSON...');
      try {
        const repairedText = repairJSON(cleanedText);
        receiptData = JSON.parse(repairedText);
        console.log('✅ JSON successfully repaired and parsed!');
      } catch (repairError) {
        console.error('JSON repair failed:', repairError.message);
        console.error('Failed to parse (first 500 chars):', cleanedText.substring(0, 500));
        console.error('Failed to parse (last 200 chars):', cleanedText.substring(Math.max(0, cleanedText.length - 200)));

        return res.status(500).json({
          error: 'Receipt data format error',
          message: 'The receipt was analyzed but the data format is invalid. This is usually temporary - please try scanning again.',
          details: parseError.message,
          hint: 'If this persists, try taking a clearer photo with better lighting'
        });
      }
    }

    // Transform new structure to backwards-compatible format for existing code
    // while also keeping the rich metadata
    const transformedData = transformReceiptData(receiptData);

    // Validate the transformed data
    const validation = validateReceipt(transformedData);

    // Add validation info to response
    transformedData._validation = validation;

    return res.status(200).json(transformedData);

  } catch (error) {
    console.error('Error processing receipt:', error);

    // Provide more helpful error messages
    let userMessage = 'Failed to process receipt';
    if (error.message.includes('fetch')) {
      userMessage = 'Could not connect to AI service. Please check your internet connection.';
    } else if (error.message.includes('timeout')) {
      userMessage = 'Request timed out. Please try again.';
    } else if (error.message.includes('JSON')) {
      userMessage = 'Could not understand the receipt. Please try a clearer image.';
    }

    return res.status(500).json({
      error: userMessage,
      message: error.message,
      type: error.name
    });
  }
}
