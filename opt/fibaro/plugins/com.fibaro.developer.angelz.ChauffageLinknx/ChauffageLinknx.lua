-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Name: ChauffageLinknx
-- Type: Plugin
-- Version: 1.0.0 beta
-- Release date: 20-10-2014
-- Author: Fabrice Bernardi
-------------------------------------------------------------------------------------------



--! includes
require('common.device')
require('net.HTTPClient')

class 'ChauffageLinknx' (Device)
local id_plugin
local configured
local temp_pool
local ip_hc2
local globalConfigured

--@param id: Id of the device.
function ChauffageLinknx:__init(id)
  Device.__init(self, id)
  id_plugin = id
  temp_pool = 0
  self.http = net.HTTPClient({ timeout = 10000 })
  self:test_prop()
  
end


function ChauffageLinknx:get_ip_hc2()
    local url = 'http://127.0.0.1:11111/api/settings/network'
    self.headers = {
            }
     self.http:request(url, {
        options = {
            method = 'GET',
            headers = self.headers
        },
        success = function(response) 
           if (response.status == 200 and response.data) then
              local result_json = json.decode(response.data)
                if result_json.ip then
                --    self:updateProperty('ui.debug.caption', 'response mode= ' .. tostring(result_json.ip))
                    ip_hc2 = tostring(result_json.ip)
                    self:init_temp_piece()  
           
              end
            end
        end,
        error = function(err) print(err) end
    })
end


function ChauffageLinknx:test_prop()
  self:updateProperty('supportedModes','1,2,11' )
  local configured = false
  
  local ip_nodejs = self.properties.ip_nodejs
  local port_nodejs = self.properties.port_nodejs
  local id_linknx_mode = self.properties.id_linknx_mode
  local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
  local id_linknx_actuel_consigne = self.properties.id_linknx_actuel_consigne
  local id_linknx_temp_local = self.properties.id_linknx_temp_local

  if(ip_nodejs == '') then
    configured = false
  else
    configured = true
  end
  
  if(port_nodejs == '') then
    configured = false
  else
    configured = true
  end

  if(id_linknx_mode == '') then
    configured = false
  else
    configured = true
  end

  if(id_linknx_demande_consigne == '') then
    configured = false
  else
    configured = true
  end

  if(id_linknx_actuel_consigne == '') then
    configured = false
  else
    configured = true
  end

  if(id_linknx_temp_local == '') then
    configured = false
  else
    configured = true
  end


  if(tostring(configured) == 'true') then
    self:updateProperty('configured',true)
    globalConfigured = true;
    self:updateProperty('ui.debug.caption', '')
    self:get_ip_hc2()  
  else
    self:updateProperty('configured',false)
    self:updateProperty('ui.debug.caption', 'Paramètres de configuration Manquant')
    globalConfigured = false
   -- self.test_prop(id)
  end

end

function ChauffageLinknx:change_mode(mode)
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_mode = self.properties.id_linknx_mode
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_mode .. '&value=' .. mode
      
    self:gestion_bouton(mode)
   
    if(tostring(mode) == "comfort") then
      self:updateProperty('mode',1)
    elseif(tostring(mode) == "night") then
      self:updateProperty('mode',11)
    elseif(tostring(mode) == "frost") then
      self:updateProperty('mode',2)
    elseif(tostring(mode) == "standby") then
      self:updateProperty('mode',11)
    end

    self:httpRequest(url)
    self:updateProperty('ui.icone.source','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/'  .. mode .. '.png')
  end    
end

function ChauffageLinknx:consigne_plus()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
    local id_linknx_actuel_consigne = self.properties.id_linknx_actuel_consigne
    local temp_actuel =  plugin.getProperty(id_plugin, 'ui.temp_consigne.caption')
    local new_temp_actuel = tonumber(temp_actuel) + 1 / 2
    self:updateProperty('ui.temp_consigne.caption',tostring(new_temp_actuel))
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_demande_consigne .. '&value=' .. new_temp_actuel
    self:httpRequest(url)
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_actuel_consigne .. '&value=' .. new_temp_actuel
    self:httpRequest(url)
    self:updateProperty('targetLevel',tonumber(new_temp_actuel))  
  end

end


function ChauffageLinknx:consigne_moins()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
    local id_linknx_actuel_consigne = self.properties.id_linknx_actuel_consigne
    local temp_actuel =  plugin.getProperty(id_plugin, 'ui.temp_consigne.caption')
    local new_temp_actuel = tonumber(temp_actuel) - 1 / 2
    self:updateProperty('ui.temp_consigne.caption',tostring(new_temp_actuel))
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_demande_consigne .. '&value=' .. new_temp_actuel
    self:httpRequest(url)
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_actuel_consigne .. '&value=' .. new_temp_actuel
    self:httpRequest(url)
    self:updateProperty('targetLevel',tonumber(new_temp_actuel))  
  end
end

--! Prepares HTTPClient object to do http request on freebox
--@param url The url
function ChauffageLinknx:httpRequest(url)
  self.headers = {
            }
   self.http:request(url, {
        options = {
            method = 'GET',
            headers = self.headers
        },
        success = function(data) print(data.status) end,
        error = function(err) print(err) end
    })
end


--! [public] Restart action
function ChauffageLinknx:restartPlugin()
  plugin.restart()
end


function ChauffageLinknx:init_temp_piece()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_temp_local = self.properties.id_linknx_temp_local
    
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/etat_linknx_1_obj?id_linknx=' .. id_linknx_temp_local 
   -- self:updateProperty('ui.debug.caption',tostring(url))
    
    self.headers = {
              }
     self.http:request(url, {
          options = {
              method = 'GET',
              headers = self.headers
          },
          success = function(response) 
             if (response.status == 200 and response.data) then
                local result_json = json.decode(response.data)
                if result_json.objects then
                  if result_json.objects[1] then
                        local objet = result_json.objects[1]
                        local objet_json = objet
                        local id_linknx  = objet_json.id
                        local value  = objet_json.value
                        self:updateProperty('ui.temp_local.caption', value .. '°')
                        -- on appel la fonction pour la reception du mode
                        self:updateProperty('value',tonumber(value)) 

                        self:init_mode()
                  end
                end
              end
          end,
          error = function(err) self:updateProperty('ui.debug.caption', 'Err : ' .. err) end
      })
  end
end


function ChauffageLinknx:init_mode()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_mode = self.properties.id_linknx_mode
    
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/etat_linknx_1_obj?id_linknx=' .. id_linknx_mode 
   -- self:updateProperty('ui.debug.caption',tostring(url))
    
    self.headers = {
              }
     self.http:request(url, {
          options = {
              method = 'GET',
              headers = self.headers
          },
          success = function(response) 
           -- self:updateProperty('ui.debug.caption', 'response mode= ' .. tostring(response))
             if (response.status == 200 and response.data) then
                local result_json = json.decode(response.data)
                if result_json.objects then
                  if result_json.objects[1] then
                     --   self:updateProperty('ui.debug.caption', 'result_json.objects[1] mode= ' .. tostring(result_json.objects[1]))
                        local objet = result_json.objects[1]
                        local objet_json = objet
                        local id_linknx  = objet_json.id
                        local value  = objet_json.value
                        self:gestion_bouton(value)
                        -- on appel la fonction pour la temperature de consigne

                        if(tostring(value) == "comfort") then
                          self:updateProperty('mode',1)
                        elseif(tostring(value) == "night") then
                          self:updateProperty('mode',11)
                        elseif(tostring(value) == "frost") then
                          self:updateProperty('mode',2)
                        elseif(tostring(value) == "standby") then
                          self:updateProperty('mode',11)
                        end

                        self:updateProperty('ui.icone.source','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/'  .. tostring(value) .. '.png')



                        self:init_temp_consigne()
                  end
                end
              end
          end,
          error = function(err) self:updateProperty('ui.debug.caption', 'Err : ' .. err) end
      })
  end
end




function ChauffageLinknx:init_temp_consigne()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
    
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/etat_linknx_1_obj?id_linknx=' .. id_linknx_demande_consigne 
    self.headers = {
              }
     self.http:request(url, {
          options = {
              method = 'GET',
              headers = self.headers
          },
          success = function(response) 
             if (response.status == 200 and response.data) then
                local result_json = json.decode(response.data)
                if result_json.objects then
                  if result_json.objects[1] then
                        local objet = result_json.objects[1]
                        local objet_json = objet
                        local id_linknx  = objet_json.id
                        local value  = objet_json.value
                        self:updateProperty('ui.temp_consigne.caption', value )
                        self:updateProperty('targetLevel',tonumber(value)) 
                       

                  end
                end
              end
          end,
          error = function(err) self:updateProperty('ui.debug.caption', 'Err : ' .. err) end
      })
  end
end
function ChauffageLinknx:receive_data(id,value)
  if (globalConfigured == true) then
    local value_recu = tostring(value)
    local id_recu = tostring(id)
    local id_linknx_mode = self.properties.id_linknx_mode
    local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
    local id_linknx_actuel_consigne = self.properties.id_linknx_actuel_consigne
    local id_linknx_temp_local = self.properties.id_linknx_temp_local
   -- self:updateProperty('ui.debug.caption',  id_recu .. ' = ' .. value_recu )

    if(id_recu == tostring(id_linknx_mode)) then
        self:updateProperty('ui.icone.source','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/'  .. value_recu .. '.png') 
        


        if(tostring(value_recu) == "comfort") then
          self:updateProperty('mode',1)
        elseif(tostring(value_recu) == "night") then
          self:updateProperty('mode',11)
        elseif(tostring(value_recu) == "frost") then
          self:updateProperty('mode',2)
        elseif(tostring(value_recu) == "standby") then
          self:updateProperty('mode',11)
        end




        self:gestion_bouton(value_recu)
    elseif(id_recu == tostring(id_linknx_actuel_consigne)) then
        self:updateProperty('targetLevel',tonumber(value_recu)) 
        self:updateProperty('ui.temp_consigne.caption', value_recu )
    elseif(id_recu == tostring(id_linknx_demande_consigne)) then
        self:updateProperty('targetLevel',tonumber(value_recu))
        self:updateProperty('ui.temp_consigne.caption', value_recu )
    elseif(id_recu == tostring(id_linknx_temp_local)) then
        self:updateProperty('ui.temp_local.caption', value_recu .. '°')
        self:updateProperty('value',tonumber(value_recu))
    end
  end
end




function ChauffageLinknx:gestion_bouton(mode)
   -- self:updateProperty('ui.debug.caption', mode)
                      
    if (mode == 'comfort') then
      self:updateProperty('ui.Key_confort.image','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/bp_on.png')
      self:updateProperty('ui.Key_eco.image','')
      self:updateProperty('ui.Key_nuit.image','')
      self:updateProperty('ui.Key_horsGel.image','')

    elseif(tostring(mode) == 'standby') then
      self:updateProperty('ui.Key_eco.image','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/bp_on.png')
      self:updateProperty('ui.Key_confort.image','')
      self:updateProperty('ui.Key_nuit.image','')
      self:updateProperty('ui.Key_horsGel.image','')
    elseif(tostring(mode) == 'night') then
      self:updateProperty('ui.Key_nuit.image','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/bp_on.png')
      self:updateProperty('ui.Key_confort.image','')
      self:updateProperty('ui.Key_eco.image','')
      self:updateProperty('ui.Key_horsGel.image','')
    elseif(tostring(mode) == 'frost') then
      self:updateProperty('ui.Key_horsGel.image','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.ChauffageLinknx/img/bp_on.png')
      self:updateProperty('ui.Key_confort.image','')
      self:updateProperty('ui.Key_eco.image','')
      self:updateProperty('ui.Key_nuit.image','')
    end
end


function ChauffageLinknx:change_val(id,value)
  if (globalConfigured == true) then
    local value_recu = tostring(value)
    local id_recu = tostring(id)
    local id_linknx_mode = self.properties.id_linknx_mode
    local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
    local id_linknx_actuel_consigne = self.properties.id_linknx_actuel_consigne
   -- self:updateProperty('ui.debug.caption',  id_recu .. ' = ' .. value_recu )

    if(id_recu == tostring(id_linknx_mode)) then
        self:change_mode(value_recu)
    elseif(id_recu == tostring(id_linknx_actuel_consigne)) then
        self:updateProperty('ui.temp_consigne.caption',tostring(value))
        local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_demande_consigne .. '&value=' .. value
        self:httpRequest(url)
    elseif(id_recu == tostring(id_linknx_demande_consigne)) then
        self:updateProperty('ui.temp_consigne.caption',tostring(value))
        local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_demande_consigne .. '&value=' .. value
        self:httpRequest(url)
    end
  end
end

function ChauffageLinknx:setThermostatSetpoint(mode_tuile, temp_consigne_tuile) 
  if (globalConfigured == true) then
    if(tostring(mode_tuile) == "1") then
      self:change_mode('comfort')
    elseif(tostring(mode_tuile) == "11") then
      self:change_mode('night')
    elseif(tostring(mode_tuile) == "2") then
      self:change_mode('frost')
    end

    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_demande_consigne = self.properties.id_linknx_demande_consigne
    local id_linknx_actuel_consigne = self.properties.id_linknx_actuel_consigne
    self:updateProperty('ui.temp_consigne.caption',tostring(temp_consigne_tuile))
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_demande_consigne .. '&value=' .. temp_consigne_tuile
    self:httpRequest(url)
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_actuel_consigne .. '&value=' .. temp_consigne_tuile
    self:httpRequest(url)
    self:updateProperty('targetLevel',tonumber(temp_consigne_tuile)) 
  end
end 

function ChauffageLinknx:setSetpointMode(mode_tuile)
  if(tostring(mode_tuile) == "1") then
    self:change_mode('comfort')
  elseif(tostring(mode_tuile) == "11") then
    self:change_mode('night')
  elseif(tostring(mode_tuile) == "2") then
    self:change_mode('frost')
  end
end