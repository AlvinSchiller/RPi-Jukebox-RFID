import React, { forwardRef, useEffect, useState } from 'react';
import {
  Link,
  useLocation,
} from 'react-router-dom';
import { useTranslation } from 'react-i18next';

import {
  ListItem,
  ListItemButton,
  ListItemText,
} from '@mui/material';

const AlbumListItem = ({ albumartist, album, isButton = true }) => {
  const { t } = useTranslation();
  const { search: urlSearch } = useLocation();

  const AlbumLink = forwardRef((props, ref) => {
    const { data } = props;

    const artist = encodeURIComponent(data?.albumartist || t('library.albums.unknown-artist'));
    const album = encodeURIComponent(data?.album || t('library.albums.unknown-album'));

    // TODO: Introduce fallback incase artist or album are undefined
    const location = `${artist}/${album}${urlSearch}`;

    return <Link ref={ref} to={location} {...props} />
  });

  return (
    <ListItem
      button={isButton}
      component={isButton ? AlbumLink : null}
      data={{ albumartist, album }}
      disablePadding
      key={album}
    >
      <ListItemButton>
        <ListItemText
          primary={album || t('library.albums.unknown-album')}
          secondary={albumartist || null}
        />
      </ListItemButton>
    </ListItem>
  );
}

export default AlbumListItem;
