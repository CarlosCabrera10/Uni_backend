import { supabase } from "../config/supabaseClient.js";

export const signUp = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ error: "Missing email or password" });

    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) return res.status(400).json({ error: error.message || error });
    return res.json({ data });
  } catch (err) {
    console.error("Unexpected error in signUp:", err);
    return res.status(500).json({ error: err.message || String(err) });
  }
};

export const signIn = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ error: "Missing email or password" });

    console.log(`Auth attempt for email: ${email}`);

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) {
      console.warn("Supabase auth error:", error.message || error);
      // Invalid credentials
      return res
        .status(401)
        .json({ error: error.message || "Invalid credentials" });
    }

    const user = data?.user;
    if (!user || !user.id) {
      console.error("Auth succeeded but user info missing", { data });
      return res
        .status(500)
        .json({ error: "Auth succeeded but user info missing" });
    }

    // Verify application-level Usuario row and role === 'empresa'
    try {
      const { data: usuarioData, error: usuarioErr } = await supabase
        .from("usuario")
        .select("rol")
        .eq("id_usuario", user.id)
        .limit(1);

      if (usuarioErr) {
        console.error("Error querying usuario table:", usuarioErr);
        return res
          .status(500)
          .json({ error: usuarioErr.message || String(usuarioErr) });
      }

      const usuario = Array.isArray(usuarioData) ? usuarioData[0] : usuarioData;

      if (!usuario) {
        // No application user row -> treat as not authorized
        return res
          .status(403)
          .json({ error: "Forbidden: user not registered as empresa" });
      }

      if (usuario.rol !== "empresa") {
        return res
          .status(403)
          .json({ error: "Forbidden: only users with rol=empresa can log in" });
      }
    } catch (chkErr) {
      console.error("Unexpected error checking usuario role:", chkErr);
      return res.status(500).json({ error: chkErr.message || String(chkErr) });
    }

    // Return success, minimal user info and the session (access token)
    return res.json({
      ok: true,
      session: data.session || null,
      user: { id: user.id, email: user.email }
    });
  } catch (err) {
    console.error("Unexpected error in signIn:", err);
    return res.status(500).json({ error: err.message || String(err) });
  }
};

export const signOut = async (req, res) => {
  const { error } = await supabase.auth.signOut();
  if (error) return res.status(400).json({ error: error.message || error });
  return res.json({ ok: true });
};

// Dev-only: create Usuario, Perfil and Perfil_empresa for a given auth user id
export const seedCompany = async (req, res) => {
  try {
    const devKey = process.env.SEED_KEY;
    const { devSeedKey, authUserId, nombre_comercial, telefono } = req.body;
    if (!devKey || devSeedKey !== devKey) {
      return res.status(403).json({ error: "Forbidden: invalid seed key" });
    }

    if (!authUserId)
      return res.status(400).json({ error: "authUserId required" });

    // Create Usuario row
    const { data: uData, error: uErr } = await supabase
      .from("usuario")
      .insert([{ id_usuario: authUserId, rol: "empresa", estado: "activo" }]);
    if (uErr) return res.status(500).json({ error: uErr.message || uErr });

    // Create Perfil
    const { data: pData, error: pErr } = await supabase
      .from("perfil")
      .insert([
        {
          id_usuario: authUserId,
          nombre_completo: nombre_comercial || "Empresa de prueba",
          foto_perfil: null,
          biografia: "Perfil creado por seed",
          ubicacion: "Desconocida",
          telefono: telefono || "",
          sitio_web: null
        }
      ])
      .select();
    if (pErr) return res.status(500).json({ error: pErr.message || pErr });

    const perfil = Array.isArray(pData) ? pData[0] : pData;

    // Create Perfil_empresa using id_perfil
    const { data: peData, error: peErr } = await supabase
      .from("perfil_empresa")
      .insert([
        {
          id_perfil: perfil.id_perfil,
          nombre_comercial: nombre_comercial || "Empresa de prueba",
          anio_fundacion: 2020,
          total_empleados: 10,
          doc_verificacion: null
        }
      ])
      .select();
    if (peErr) return res.status(500).json({ error: peErr.message || peErr });

    return res.json({
      usuario: uData?.[0] || uData,
      perfil,
      perfil_empresa: peData?.[0] || peData
    });
  } catch (err) {
    console.error("seedCompany error:", err);
    return res.status(500).json({ error: err.message || String(err) });
  }
};
