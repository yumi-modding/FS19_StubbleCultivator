StubbleCultivatorEvent = {};
StubbleCultivatorEvent_mt = Class(StubbleCultivatorEvent, Event);

InitEventClass(StubbleCultivatorEvent, "StubbleCultivatorEvent");

function StubbleCultivatorEvent:emptyNew()
  if StubbleCultivator.debug then print("StubbleCultivatorEvent:emptyNew() ") end
  local self = Event:new(StubbleCultivatorEvent_mt);
  self.className="StubbleCultivatorEvent";
  return self;
end;

function StubbleCultivatorEvent:new(object, isActive, isAlwaysActive)
  if StubbleCultivator.debug then print("StubbleCultivatorEvent:new() ") end
  local self = StubbleCultivatorEvent:emptyNew()
  self.object = object;
  self.isActive = isActive;
  self.isAlwaysActive = isAlwaysActive;
  return self;
end;

function StubbleCultivatorEvent:readStream(streamId, connection)
  if StubbleCultivator.debug then print("StubbleCultivatorEvent:readStream() ") end
  self.object = NetworkUtil.readNodeObject(streamId);
  self.isActive = streamReadBool(streamId);
  self.isAlwaysActive = streamReadBool(streamId);
  self:run(connection);
end;

function StubbleCultivatorEvent:writeStream(streamId, connection)
  if StubbleCultivator.debug then print("StubbleCultivatorEvent:writeStream() ") end
  NetworkUtil.writeNodeObject(streamId, self.object);
  streamWriteBool(streamId, self.isActive);
  streamWriteBool(streamId, self.isAlwaysActive);
end;

function StubbleCultivatorEvent:run(connection)
  if StubbleCultivator.debug then print("StubbleCultivatorEvent:run() ") end
  self.object:setStubbleCultivatorActive(self.isActive, self.isAlwaysActive, true);
  if not connection:getIsServer() then
    g_server:broadcastEvent(self, false, connection, self.object);
  end;
  if self.object ~= nil then
    self.object:setStubbleCultivatorActive(self.isActive, self.isAlwaysActive, true)
  end
end;

function StubbleCultivatorEvent.sendEvent(vehicle, isActive, isAlwaysActive, noEventSend)
  if StubbleCultivator.debug then print("StubbleCultivatorEvent.sendEvent() ") end
  if noEventSend == nil or noEventSend == false then
    if g_server ~= nil then
      g_server:broadcastEvent(StubbleCultivatorEvent:new(vehicle, isActive, isAlwaysActive), nil, nil, vehicle);
    else
      g_client:getServerConnection():sendEvent(StubbleCultivatorEvent:new(vehicle, isActive, isAlwaysActive));
    end;
  end;
end;
