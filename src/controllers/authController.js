import { supabase } from "../config/supabaseClient.js";
import { getFullUserProfile } from "../models/userModel.js";

export const signIn = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        error: "Email and password are required"
      });
    }

    // Authenticate with Supabase
    const { data: authData, error: authError } =
      await supabase.auth.signInWithPassword({
        email,
        password
      });

    if (authError) {
      return res.status(401).json({
        error: authError.message
      });
    }

    // Get user profile from database
    const { data: profileData, error: profileError } = await getFullUserProfile(
      authData.user.id
    );

    if (profileError) {
      return res.status(500).json({
        error: "Failed to fetch user profile"
      });
    }

    // Check if user role is "empresa"
    if (!profileData.usuario || profileData.usuario.rol !== "empresa") {
      return res.status(401).json({
        error: "Credenciales invalidas para empresa"
      });
    }

    // Return token and user info
    res.json({
      token: authData.session.access_token,
      user: {
        id: authData.user.id,
        email: authData.user.email,
        ...profileData
      }
    });
  } catch (error) {
    console.error("Sign in error:", error);
    res.status(500).json({
      error: "Internal server error"
    });
  }
};

export const signUp = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        error: "Email and password are required"
      });
    }

    // Create user with Supabase
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password
    });

    if (authError) {
      return res.status(400).json({
        error: authError.message
      });
    }

    // Return success response
    res.status(201).json({
      message: "User created successfully",
      user: {
        id: authData.user.id,
        email: authData.user.email
      }
    });
  } catch (error) {
    console.error("Sign up error:", error);
    res.status(500).json({
      error: "Internal server error"
    });
  }
};
export const signOut = async (req, res) => {
  try {
    const { error } = await supabase.auth.signOut();

    if (error) {
      return res.status(400).json({
        error: error.message
      });
    }

    res.json({
      message: "Signed out successfully"
    });
  } catch (error) {
    console.error("Sign out error:", error);
    res.status(500).json({
      error: "Internal server error"
    });
  }
};

export const seedCompany = async (req, res) => {
  try {
    const {
      email,
      password,
      nombre_comercial,
      anio_fundacion,
      total_empleados
    } = req.body;

    if (
      !email ||
      !password ||
      !nombre_comercial ||
      !anio_fundacion ||
      !total_empleados
    ) {
      return res.status(400).json({
        error:
          "All fields are required: email, password, nombre_comercial, anio_fundacion, total_empleados"
      });
    }

    // Create user with Supabase
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password
    });

    if (authError) {
      return res.status(400).json({
        error: authError.message
      });
    }

    // Insert into Usuario table
    const { data: usuarioData, error: usuarioError } = await supabase
      .from("usuario")
      .insert({
        id_usuario: authData.user.id,
        rol: "empresa",
        estado: "activo"
      })
      .select()
      .single();

    if (usuarioError) {
      return res.status(500).json({
        error: "Failed to create usuario: " + usuarioError.message
      });
    }

    // Insert into Perfil table
    const { data: perfilData, error: perfilError } = await supabase
      .from("perfil")
      .insert({
        id_usuario: authData.user.id,
        nombre_completo: nombre_comercial,
        biografia: `Empresa ${nombre_comercial} fundada en ${anio_fundacion}`,
        ubicacion: "El Salvador",
        telefono: "00000000",
        sitio_web: null
      })
      .select()
      .single();

    if (perfilError) {
      return res.status(500).json({
        error: "Failed to create perfil: " + perfilError.message
      });
    }

    // Insert into Perfil_empresa table
    const { data: empresaData, error: empresaError } = await supabase
      .from("perfil_empresa")
      .insert({
        id_perfil: perfilData.id_perfil,
        nombre_comercial,
        anio_fundacion,
        total_empleados,
        doc_verificacion: "pending"
      })
      .select()
      .single();

    if (empresaError) {
      return res.status(500).json({
        error: "Failed to create perfil_empresa: " + empresaError.message
      });
    }

    res.status(201).json({
      message: "Company seeded successfully",
      user: {
        id: authData.user.id,
        email: authData.user.email,
        usuario: usuarioData,
        perfil: perfilData,
        perfil_empresa: empresaData
      }
    });
  } catch (error) {
    console.error("Seed company error:", error);
    res.status(500).json({
      error: "Internal server error"
    });
  }
};

export const debugHeaders = async (req, res) => {
  res.json({
    headers: req.headers,
    method: req.method,
    url: req.url,
    body: req.body
  });
};
