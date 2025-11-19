import { supabase } from "../config/supabaseClient.js";

export const protect = async (req, res, next) => {
  try {
    const auth = req.headers.authorization;
    if (!auth)
      return res.status(401).json({ error: "No authorization header" });
    const parts = auth.split(" ");
    if (parts.length !== 2 || parts[0] !== "Bearer")
      return res.status(401).json({ error: "Invalid authorization format" });
    const token = parts[1];

    // Verificar token con Supabase
    const { data, error } = await supabase.auth.getUser(
      token ? { access_token: token } : undefined
    );
    if (error || !data?.user)
      return res.status(401).json({ error: "Invalid or expired token" });

    req.user = data.user;
    next();
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

export default protect;
