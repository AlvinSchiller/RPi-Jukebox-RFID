import time

import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)


def parse_edge_key(edge):
    if edge in [GPIO.FALLING, GPIO.RISING, GPIO.BOTH]:
        edge
    elif edge.lower() == 'falling':
        edge = GPIO.FALLING
    elif edge.lower() == 'raising':
        edge = GPIO.RISING
    elif edge.lower() == 'both':
        edge = GPIO.BOTH
    else:
        raise KeyError('Unknown Edge type {edge}'.format(edge=edge))
    return edge



# This function takes a holding time (fractional seconds), a channel, a GPIO state and an action reference (function).
# It checks if the GPIO is in the state since the function was called. If the state
# changes it return False. If the time is over the function returns True.
def checkGpioStaysInState(holdingTime, gpioChannel, gpioHoldingState):
    # Get a reference start time (https://docs.python.org/3/library/time.html#time.perf_counter)
    startTime = time.perf_counter()
    # Continously check if time is not over
    while True:
        currentState = GPIO.input(gpioChannel)
        if holdingTime < (time.perf_counter() - startTime):
            break
        # Return if state does not match holding state
        if (gpioHoldingState != currentState):
            return False
        # Else: Wait

    if (gpioHoldingState != currentState):
        return False
    return True


class SimpleButton:
    def callbackFunctionHandler(self, *args):
        if self.hold_repeat:
            return self.holdAndRepeatHandler(*args)
        return self.when_pressed(*args)

    def __init__(self, pin, action=lambda *args: None, name=None, bouncetime=500, edge=GPIO.FALLING,
                 hold_time=.1, hold_repeat=False):
        self.edge = parse_edge_key(edge)
        self.hold_time = hold_time
        self.hold_repeat = hold_repeat
        self.pull_up = True

        self.pin = pin
        self.name = name
        self.bouncetime = bouncetime
        GPIO.setup(self.pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        self.when_pressed = action
        GPIO.add_event_detect(self.pin, edge=self.edge, callback=self.callbackFunctionHandler,
                              bouncetime=self.bouncetime)

    def set_callbackFunction(self, callbackFunction):
        self.when_pressed = callbackFunction

    def holdAndRepeatHandler(self, *args):
        # Rise volume as requested
        self.when_pressed(*args)
        # Detect holding of button
        while checkGpioStaysInState(self.hold_time, self.pin, GPIO.LOW):
            self.when_pressed(*args)

    def __del__(self):
        GPIO.remove_event_detect(self.pin)

    @property
    def is_pressed(self):
        if self.pull_up:
            return not GPIO.input(self.pin)
        return GPIO.input(self.pin)

    def __repr__(self):
        return '<SimpleButton-{}(pin {},hold_repeat={},hold_time={})>'.format(
            self.name, self.pin, self.hold_repeat, self.hold_time
        )


if __name__ == "__main__":
    print('please enter pin no to test')
    pin = int(input())
    func = lambda *args: print('FunctionCall with {}'.format(args))
    btn = SimpleButton(pin=pin, action=func, hold_repeat=True)
    while True:
        pass
