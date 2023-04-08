import React from 'react';

import CommandSelector from '../../command-selector';
import ChangeOnRfidScan from './change-on-rfid-scan-options';

import { getActionAndCommand } from '../../../utils';

const SelectSynchronisation = ({
  actionData,
  handleActionDataChange,
}) => {
  const { command } = getActionAndCommand(actionData);

  return (
    <>
      <CommandSelector
        actionData={actionData}
        handleActionDataChange={handleActionDataChange}
      />
      {command === 'sync_shared_change_on_rfid_scan' &&
        <ChangeOnRfidScan
          actionData={actionData}
          handleActionDataChange={handleActionDataChange}
        />
      }
    </>
  );
};

export default SelectSynchronisation;