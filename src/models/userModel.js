import { supabase } from "../config/supabaseClient.js";

export const getPerfilByUserId = async (id_usuario) => {
  return supabase
    .from("Perfil")
    .select("*")
    .eq("id_usuario", id_usuario)
    .limit(1)
    .single();
};

export const getPerfilById = async (id_perfil) => {
  return supabase
    .from("Perfil")
    .select("*")
    .eq("id_perfil", id_perfil)
    .limit(1)
    .single();
};
