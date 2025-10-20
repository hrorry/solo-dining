// Vercel Serverless Function for Google Places API
const https = require('https');

module.exports = async (req, res) => {
  // CORS設定
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,POST');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // OPTIONSリクエスト（プリフライト）への対応
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const { latitude, longitude, radius = 1500, type = 'restaurant', query } = req.query;
  const apiKey = process.env.PLACES_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'PLACES_API_KEY not configured' });
  }

  let url;

  // queryパラメータがある場合はText Search、なければNearby Search
  if (query) {
    // Google Places API Text Search
    url = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(query)}+restaurant&type=${type}&key=${apiKey}&language=ja`;
  } else if (latitude && longitude) {
    // Google Places API Nearby Search
    url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=${radius}&type=${type}&key=${apiKey}&language=ja`;
  } else {
    return res.status(400).json({ error: 'Either query or (latitude and longitude) is required' });
  }

  try {
    // httpsモジュールを使ってリクエスト（Node.js互換）
    const json = await new Promise((resolve, reject) => {
      https.get(url, (response) => {
        let data = '';

        response.on('data', (chunk) => {
          data += chunk;
        });

        response.on('end', () => {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error('Failed to parse JSON response'));
          }
        });
      }).on('error', (error) => {
        reject(error);
      });
    });

    if (json.status !== 'OK' && json.status !== 'ZERO_RESULTS') {
      return res.status(500).json({
        error: 'Places API error',
        status: json.status,
        message: json.error_message
      });
    }

    // レスポンスを整形（Nearby SearchとText Searchで共通）
    const restaurants = (json.results || []).map(place => ({
      place_id: place.place_id || '',
      name: place.name || '不明',
      vicinity: place.vicinity || place.formatted_address || '住所不明',
      formatted_address: place.formatted_address || place.vicinity || '住所不明',
      rating: place.rating || 0.0,
      user_ratings_total: place.user_ratings_total || 0,
      latitude: place.geometry?.location?.lat || 0,
      longitude: place.geometry?.location?.lng || 0,
      types: place.types || [],
      photos: (place.photos || []).map(photo => ({
        photo_reference: photo.photo_reference,
        width: photo.width,
        height: photo.height,
      })),
      price_level: place.price_level || 0,
      opening_hours: place.opening_hours ? {
        open_now: place.opening_hours.open_now || false,
      } : null,
    }));

    res.status(200).json({
      status: 'success',
      results: restaurants,
      count: restaurants.length,
    });
  } catch (error) {
    console.error('Error fetching from Places API:', error);
    res.status(500).json({
      error: 'Failed to fetch from Places API',
      message: error.message
    });
  }
};
