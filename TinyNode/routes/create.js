import express from "express"
import checkAccessToken from "../tokens.js"
const router = express.Router()

/* POST a create to the thing. */
router.post('/', checkAccessToken, async (req, res, next) => {

  try {
    // check body for JSON
    const body = JSON.stringify(req.body)
    const createOptions = {
      method: 'POST',
      body,
      headers: {
        'user-agent': 'Tiny-Things/1.0',
        'Authorization': `Bearer ${process.env.ACCESS_TOKEN}`,
        'Content-Type' : "application/json;charset=utf-8"
      }
    }
    const createURL = `${process.env.RERUM_API_ADDR}create`
    const result = await fetch(createURL, createOptions).then(res => {
      if (!res.ok) {
        throw new Error(`RERUM API error: ${res.status}`);
      }
      return res.json();
    });

      // Save to MongoDB
    const db = await connectDB();
    const collection = db.collection('testing');
    await collection.insertOne({
        ...req.body,
        rerumId: result["@id"] ?? result.id,
        createdAt: new Date()
    });

    res.setHeader("Location", result["@id"] ?? result.id)
    res.status(201)
    res.json(result)
  }
  catch (err) {
    next(err)
  }
})

router.all('/', (req, res, next) => {
  res.status(405).send("Method Not Allowed")
})

export default router