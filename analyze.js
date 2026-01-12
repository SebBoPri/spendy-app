// Vercel Serverless Function to handle receipt analysis
// This keeps your API key secure on the server side

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Enable CORS
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
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
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
              text: `Analyze this receipt. Return ONLY valid JSON, no other text.

RULES:
1. Only JSON output
2. Use null if info not visible
3. All prices in SEK

Structure:
{
  "store": "name or null",
  "date": "YYYY-MM-DD or null",
  "items": [
    {
      "name": "item name",
      "price": 0.00,
      "category": "category",
      "subcategory": "subcategory or null"
    }
  ],
  "total": 0.00
}

Categories: Groceries, Household, Personal Care, Electronics, Clothing, Dining, Transportation, Health, Entertainment, Other
Grocery subcategories: Produce, Dairy, Meat, Bakery, Beverages, Snacks, Frozen, Pantry`
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
    
    // Clean up JSON
    let cleanedText = textContent.trim()
      .replace(/```json\n?/g, '')
      .replace(/```/g, '');
    
    const jsonMatch = cleanedText.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      cleanedText = jsonMatch[0];
    }
    
    // Parse and validate
    const receiptData = JSON.parse(cleanedText);
    
    if (!receiptData.items || !Array.isArray(receiptData.items)) {
      return res.status(400).json({ error: 'Invalid receipt data structure' });
    }
    
    // Return the parsed receipt data
    return res.status(200).json(receiptData);

  } catch (error) {
    console.error('Error processing receipt:', error);
    return res.status(500).json({ 
      error: 'Failed to process receipt',
      message: error.message 
    });
  }
}
