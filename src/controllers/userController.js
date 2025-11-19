import * as userModel from "../models/userModel.js";

export const getMyProfile = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(400).json({ error: "User id missing" });

    const { data, error } = await userModel.getPerfilByUserId(userId);
    if (error) return res.status(500).json({ error });
    return res.json({ data });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

export const getProfileById = async (req, res) => {
  try {
    const perfilId = Number(req.params.id);
    if (!perfilId) return res.status(400).json({ error: "Perfil id missing" });

    const { data, error } = await userModel.getPerfilById(perfilId);
    if (error) return res.status(500).json({ error });
    return res.json({ data });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
