// Monta URLs de entrega do Cloudinary a partir do publicId guardado no banco (RF-05, RF-11).
// Os tamanhos são fixos para manter o consumo de créditos baixo e previsível (seção 14).

const TRANSFORMATIONS = {
  thumbnail: 'c_fill,w_400,h_225,f_auto,q_auto',
  detail: 'w_1200,f_auto,q_auto',
} as const;

export type CloudinaryVariant = keyof typeof TRANSFORMATIONS;

interface BuildCloudinaryUrlInput {
  cloudName: string;
  publicId: string;
  variant: CloudinaryVariant;
}

export function buildCloudinaryUrl({ cloudName, publicId, variant }: BuildCloudinaryUrlInput) {
  if (!cloudName) {
    throw new Error('VITE_CLOUDINARY_CLOUD_NAME não definida');
  }

  const path = publicId.split('/').map(encodeURIComponent).join('/');

  return `https://res.cloudinary.com/${cloudName}/image/upload/${TRANSFORMATIONS[variant]}/${path}`;
}

export function cloudinaryUrl(publicId: string, variant: CloudinaryVariant) {
  return buildCloudinaryUrl({
    cloudName: import.meta.env.VITE_CLOUDINARY_CLOUD_NAME,
    publicId,
    variant,
  });
}
