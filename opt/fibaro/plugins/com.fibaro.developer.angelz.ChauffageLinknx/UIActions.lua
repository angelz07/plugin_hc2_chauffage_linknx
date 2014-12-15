-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Name: Free Mobile SMS
-- Type: Plugin
-- Version:	1.0.0 beta
-- Release date: 20-10-2014
-- Author: Fabrice Bernardi
-------------------------------------------------------------------------------------------

--! includes
require('common.device')

--! Class responsible for events types

class "UIActions"

--! Initialize UIActionsClass.
--!@param params
function UIActions:__init(params)
  print('UIActions initialize')
  self.uiBinding = params.normalBinding
end

--! Fires up on each (up, down, cancel) UI control events.
--@param deviceId: Id of the device assigned to plugin.
--@param event: Array containing eventtype (mouseup, mousedown, cancel) and UI control name.
function UIActions:onUIEvent(deviceId, event)
    print('UIActions:onUIEvent')

	if (event.eventType == 'onReleased') then
		self:mouseUp(event)
	 elseif (event.eventType == 'onPressed') then
		self:mouseDown(event)
	elseif (event.eventType == 'cancel') then
		self:cancelEvents()
	elseif (event.eventType == 'onChanged') then
		self:slideEvents(event)
	end
end 

--! Fires up on mouseup event. Cancels active run loops and fires bind method.
--@param event: Array containing eventtype (mouseup, mousedown, cancel) and UI control name.
function UIActions:mouseUp(event)
	print('UIActions:mouseUp -> onUIEvent: ' .. event.elementName .. ' EventType: ' .. event.eventType)
	local callback = self.uiBinding[event.elementName]
	if (callback) then
		callback(event)
	end
end

function UIActions:mouseDown(event)
    print('UIActions:mouseDown -> onUIEvent: ' .. event.elementName .. ' EventType: ' .. event.eventType)
end

function UIActions:cancelEvents(event)
    print('UIActions:cancelEvents -> onUIEvent: ' .. event.elementName .. ' EventType: ' .. event.eventType)
end

function UIActions:slideEvents(event)
    print('UIActions:mouseUp -> onUIEvent: ' .. event.elementName .. ' EventType: ' .. event.eventType)
	local callback = self.uiBinding[event.elementName]
	if (callback) then
		callback(event)
	end
end

