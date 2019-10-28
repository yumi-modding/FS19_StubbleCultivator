StubbleSowingMachineEvent = {};
StubbleSowingMachineEvent_mt = Class(StubbleSowingMachineEvent, Event);

InitEventClass(StubbleSowingMachineEvent, "StubbleSowingMachineEvent");

function StubbleSowingMachineEvent:emptyNew()
  if StubbleSowingMachine.debug then print("StubbleSowingMachineEvent:emptyNew() ") end
  local self = Event:new(StubbleSowingMachineEvent_mt);
  self.className="StubbleSowingMachineEvent";
  return self;
end;

function StubbleSowingMachineEvent:new(object, isActive)
  if StubbleSowingMachine.debug then print("StubbleSowingMachineEvent:new() ") end
  local self = StubbleSowingMachineEvent:emptyNew()
  self.object = object;
  self.isActive = isActive;
  return self;
end;

function StubbleSowingMachineEvent:readStream(streamId, connection)
  if StubbleSowingMachine.debug then print("StubbleSowingMachineEvent:readStream() ") end
  self.object = NetworkUtil.readNodeObject(streamId);
  self.isActive = streamReadBool(streamId);
  self:run(connection);
end;

function StubbleSowingMachineEvent:writeStream(streamId, connection)
  if StubbleSowingMachine.debug then print("StubbleSowingMachineEvent:writeStream() ") end
  NetworkUtil.writeNodeObject(streamId, self.object);
  streamWriteBool(streamId, self.isActive);
end;

function StubbleSowingMachineEvent:run(connection)
  if StubbleSowingMachine.debug then print("StubbleSowingMachineEvent:run() ") end
  self.object:setStubbleSowingMachineActive(self.isActive, true);
  if not connection:getIsServer() then
    g_server:broadcastEvent(self, false, connection, self.object);
  end;
  if self.object ~= nil then
    self.object:setStubbleSowingMachineActive(self.isActive, true)
  end
end;

function StubbleSowingMachineEvent.sendEvent(vehicle, isActive, noEventSend)
  if StubbleSowingMachine.debug then print("StubbleSowingMachineEvent.sendEvent() ") end
  if noEventSend == nil or noEventSend == false then
    if g_server ~= nil then
      g_server:broadcastEvent(StubbleSowingMachineEvent:new(vehicle, isActive), nil, nil, vehicle);
    else
      g_client:getServerConnection():sendEvent(StubbleSowingMachineEvent:new(vehicle, isActive));
    end;
  end;
end;
