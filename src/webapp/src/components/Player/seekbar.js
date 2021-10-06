import React, { useContext, useEffect, useState } from 'react';

import PlayerContext from '../../context/player/context';
import {
  progressToTime,
  timeToProgress,
  toHHMMSS,
} from '../../utils/utils';

import Grid from '@mui/material/Grid';
import Slider from '@mui/material/Slider';
import Typography from '@mui/material/Typography';

const SeekBar = () => {
  const {
    seek,
    state,
  } = useContext(PlayerContext);

  const { playerstatus } = state;

  const [isSeeking, setIsSeeking] = useState(false);
  const [progress, setProgress] = useState(0);
  const [timeElapsed, setTimeElapsed] = useState(parseFloat(playerstatus?.elapsed) || 0);
  const timeTotal = parseFloat(playerstatus?.duration) || 0;

  const updateTimeAndProgress = (newTime) => {
    setTimeElapsed(newTime);
    setProgress(timeToProgress(timeTotal, newTime));
  };

  // Handle seek events when sliding the progress bar
  const handleSeekToPosition = (event, newPosition) => {
    setIsSeeking(true);
    updateTimeAndProgress(progressToTime(timeTotal, newPosition));
  };

  // Only send commend to backend when user committed to new position
  // We don't send it while seeking (too many useless requests)
  const playFromNewTime = () => {
    seek(timeElapsed);
    setIsSeeking(false);
  };

  useEffect(() => {
    // Avoid updating time and progress when user is seeking to new
    // song position
    if (!isSeeking) {
      updateTimeAndProgress(playerstatus?.elapsed);
    }
  }, [playerstatus]);

  return <>
    <Grid container>
      <Grid item xs>
        <Slider
          aria-labelledby="Song position"
          disabled={!playerstatus?.title}
          onChange={handleSeekToPosition}
          onChangeCommitted={playFromNewTime}
          size="small"
          value={progress || 0}
        />
      </Grid>
    </Grid>
    <Grid
      alignItems="center"
      container
      direction="row"
      justifyContent="space-between"
      sx={ {
        marginTop: '-20px',
      }}
    >
      <Grid item>
        <Typography color="textSecondary">
          {toHHMMSS(parseInt(timeElapsed))}
        </Typography>
      </Grid>
      <Grid item>
        <Typography color="textSecondary">
          {toHHMMSS(parseInt(timeTotal))}
        </Typography>
      </Grid>
    </Grid>
  </>;
};

export default SeekBar;