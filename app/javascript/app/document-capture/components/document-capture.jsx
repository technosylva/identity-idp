import React, { useState } from 'react';
import {
  GridContainer,
  Grid,
  Form,
  FormGroup,
  Label,
  Button,
} from '@trussworks/react-uswds';
import useI18n from '../hooks/use-i18n';
import LoadingSpinner from './LoadingSpinner';
import { useImage } from '../hooks/use-assets';

function DocumentCapture() {
  const t = useI18n();
  const imagePath = useImage();

  const [submitted, setSubmitted] = useState(false);

  let content;

  if (submitted) {
    content = <LoadingSpinner />;
  } else {
    content = <Form onSubmit={() => setSubmitted(true)}>
      <FormGroup>
        <h2>
          {t('doc_auth.titles.doc_auth')}
        </h2>
        <Label htmlFor="front-image">
          {t('doc_auth.headings.upload_front')}
        </Label>
        <img src={imagePath('state-id-sample-front.jpg')} height={338} width={450}/>
        <input type="file" id="front-image" />
        <Label htmlFor="back-image">
          {t('doc_auth.headings.upload_back')}
        </Label>
        <img src={imagePath('state-id-sample-back.jpg')} height={338} width={450} />
        <input type="file" id="back-image" />
        <Button type="submit">
          Submit
        </Button>
      </FormGroup>
    </Form>;
  }

  return <GridContainer>
    <Grid row>
      <Grid col>
        {content}
      </Grid>
    </Grid>
  </GridContainer>;
}

export default DocumentCapture;
