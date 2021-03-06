import { render } from 'react-dom';
import {
  DocumentCapture,
  AssetContext,
  I18nContext,
  DeviceContext,
  AcuantContextProvider,
  UploadContextProvider,
  ServiceProviderContext,
  AnalyticsContext,
} from '@18f/identity-document-capture';
import { loadPolyfills } from '@18f/identity-polyfill';
import { isCameraCapableMobile } from '@18f/identity-device';

/**
 * @typedef NewRelicAgent
 *
 * @prop {(name:string,attributes:object)=>void} addPageAction Log page action to New Relic.
 */

/**
 * @typedef LoginGovI18n
 *
 * @prop {(key:string)=>string} t Translate a key.
 * @prop {()=>string} currentLocale Get current locale.
 * @prop {Record<string,string>} strings Object of strings.
 */

/**
 * @typedef LoginGov
 *
 * @prop {LoginGovI18n} I18n
 * @prop {Record<string,string>} assets
 */

/**
 * @typedef NewRelicGlobals
 *
 * @prop {NewRelicAgent=} newrelic New Relic agent.
 */

/**
 * @typedef LoginGovGlobals
 *
 * @prop {LoginGov} LoginGov
 */

/**
 * @typedef {typeof window & NewRelicGlobals & LoginGovGlobals} DocumentCaptureGlobal
 */

const { I18n: i18n, assets } = /** @type {DocumentCaptureGlobal} */ (window).LoginGov;

const appRoot = /** @type {HTMLDivElement} */ (document.getElementById('document-capture-form'));
const isMockClient = appRoot.hasAttribute('data-mock-client');

/**
 * @return {import(
 *   '@18f/identity-document-capture/context/service-provider'
 * ).ServiceProviderContext}
 */
function getServiceProvider() {
  const name = appRoot.getAttribute('data-sp-name');
  const failureToProofURL = appRoot.getAttribute('data-failure-to-proof-url');
  const isLivenessRequired = appRoot.hasAttribute('data-liveness-required');

  return { name, failureToProofURL, isLivenessRequired };
}

/**
 * @return {Record<'front'|'back'|'selfie', string>}
 */
function getBackgroundUploadURLs() {
  return ['front', 'back', 'selfie'].reduce((result, key) => {
    const url = appRoot.getAttribute(`data-${key}-image-upload-url`);
    if (url) {
      result[key] = url;
    }

    return result;
  }, /** @type {Record<'front'|'back'|'selfie', string>} */ ({}));
}

/**
 * @return {string?}
 */
function getMetaContent(name) {
  const meta = /** @type {HTMLMetaElement?} */ (document.querySelector(`meta[name="${name}"]`));
  return meta?.content ?? null;
}

/** @type {import('@18f/identity-document-capture/context/device').DeviceContext} */
const device = {
  isMobile: isCameraCapableMobile(),
};

loadPolyfills(['fetch', 'crypto']).then(async () => {
  const backgroundUploadURLs = getBackgroundUploadURLs();
  const isAsyncForm = Object.keys(backgroundUploadURLs).length > 0;

  const formData = {
    document_capture_session_uuid: appRoot.getAttribute('data-document-capture-session-uuid'),
    locale: i18n.currentLocale(),
  };

  let backgroundUploadEncryptKey;
  if (isAsyncForm) {
    backgroundUploadEncryptKey = await window.crypto.subtle.generateKey(
      {
        name: 'AES-GCM',
        length: 256,
      },
      true,
      ['encrypt', 'decrypt'],
    );

    const exportedKey = await window.crypto.subtle.exportKey('raw', backgroundUploadEncryptKey);
    formData.encryption_key = btoa(String.fromCharCode(...new Uint8Array(exportedKey)));
    formData.step = 'verify_document';
  }

  let element = (
    <AcuantContextProvider
      credentials={getMetaContent('acuant-sdk-initialization-creds')}
      endpoint={getMetaContent('acuant-sdk-initialization-endpoint')}
    >
      <UploadContextProvider
        endpoint={/** @type {string} */ (appRoot.getAttribute('data-endpoint'))}
        statusEndpoint={/** @type {string} */ (appRoot.getAttribute('data-status-endpoint'))}
        statusPollInterval={
          Number(appRoot.getAttribute('data-status-poll-interval-ms')) || undefined
        }
        method={isAsyncForm ? 'PUT' : 'POST'}
        csrf={/** @type {string} */ (getMetaContent('csrf-token'))}
        isMockClient={isMockClient}
        backgroundUploadURLs={backgroundUploadURLs}
        backgroundUploadEncryptKey={backgroundUploadEncryptKey}
        formData={formData}
      >
        <I18nContext.Provider value={i18n.strings}>
          <ServiceProviderContext.Provider value={getServiceProvider()}>
            <AssetContext.Provider value={assets}>
              <DeviceContext.Provider value={device}>
                <DocumentCapture isAsyncForm={isAsyncForm} />
              </DeviceContext.Provider>
            </AssetContext.Provider>
          </ServiceProviderContext.Provider>
        </I18nContext.Provider>
      </UploadContextProvider>
    </AcuantContextProvider>
  );

  const { newrelic } = /** @type {DocumentCaptureGlobal} */ (window);
  if (newrelic) {
    element = <AnalyticsContext.Provider value={newrelic}>{element}</AnalyticsContext.Provider>;
  }

  render(element, appRoot);
});
