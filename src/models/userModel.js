import { supabase } from "../config/supabaseClient.js";

export const getPerfilByUserId = async (id_usuario) => {
  return supabase
    .from("perfil")
    .select("*")
    .eq("id_usuario", id_usuario)
    .limit(1)
    .maybeSingle();
};

export const getPerfilById = async (id_perfil) => {
  return supabase
    .from("perfil")
    .select("*")
    .eq("id_perfil", id_perfil)
    .limit(1)
    .maybeSingle();
};

// Return combined usuario, perfil and perfil_empresa for a given auth user id
export const getFullUserProfile = async (id_usuario) => {
  try {
    const { data: usuarioData, error: usuarioErr } = await supabase
      .from("usuario")
      .select("*")
      .eq("id_usuario", id_usuario)
      .limit(1)
      .maybeSingle();

    if (usuarioErr) return { data: null, error: usuarioErr };

    const { data: perfilData, error: perfilErr } = await supabase
      .from("perfil")
      .select("*")
      .eq("id_usuario", id_usuario)
      .limit(1)
      .maybeSingle();

    if (perfilErr) return { data: null, error: perfilErr };

    let perfilEmpresa = null;
    if (perfilData && perfilData.id_perfil) {
      const { data: peData, error: peErr } = await supabase
        .from("perfil_empresa")
        .select("*")
        .eq("id_perfil", perfilData.id_perfil)
        .limit(1)
        .maybeSingle();
      if (peErr) return { data: null, error: peErr };
      perfilEmpresa = peData;
    }

    return {
      data: {
        usuario: usuarioData || null,
        perfil: perfilData || null,
        perfil_empresa: perfilEmpresa
      },
      error: null
    };
  } catch (err) {
    return { data: null, error: err };
  }
};
