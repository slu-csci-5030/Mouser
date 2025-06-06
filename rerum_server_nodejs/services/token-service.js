// token-service.js

export const trusted = new Map();

export function validateToken(token) {
  const bare = token.replace(/^Bearer\s+/i, '');
  return trusted.has(bare) ? trusted.get(bare) : null;
}
