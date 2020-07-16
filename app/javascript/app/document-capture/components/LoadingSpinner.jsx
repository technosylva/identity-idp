import React from 'react';
import { useImage } from '../hooks/use-assets';
import useI18n from '../hooks/use-i18n';

function LoadingSpinner() {
  const imagePath = useImage();
  const t = useI18n();
  return <div className="spinner">
    <img src={imagePath('wait.gif')} width={50} height={50} alt={t('image_description.spinner')} />
  </div>;
}

export default LoadingSpinner;
