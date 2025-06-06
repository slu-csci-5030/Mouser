import express from "express";
const router = express.Router();

router.post("/", async (req, res) => {
  const annotation = {
    "@context": "https://www.w3.org/ns/anno.jsonld",
    "type": "Annotation",
    "motivation": "describing",
    "body": {
      "type": "TextualBody",
      "value": req.body.observation || "No observation",
      "format": "text/plain"
    },
    "target": {
      "source": req.body.video || "unknown.mp4",
      "selector": {
        "type": "FragmentSelector",
        "conformsTo": "http://www.w3.org/TR/media-frags/",
        "value": req.body.time || "t=0,0"
      }
    }
  };

  try {
    const createRes = await fetch(`${process.env.RERUM_API_ADDR}create`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.ACCESS_TOKEN}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(annotation)
    });

    const result = await createRes.json();

    if (!createRes.ok) {
      return res.status(createRes.status).json({ error: result });
    }

    res.status(201).json(result);
  } catch (err) {
    console.error("ReRUM create error:", err);
    res.status(500).json({ error: "Failed to save to ReRUM" });
  }
});

export default router;
