---
-- cloud API (WIP)
-- push/pull queued messages from cloud, exposed as API
-- lib/cloud v0.0.1-alpha
--
-- pastebin QBfDbcaQ
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- _reply is a permanent protocol used for cloud device lookups
--
-- when '_lookup' is pushed to a host, the host leaves a response in the reply
-- protocol
--
-- All push requests are sent with a "from" key 

--
-- How to use:
--
-- 1. Register a host in the cloud for a protocol:
--    ```
--    -- cloud.register(PROTOCOL, HOSTNAME)
--    cloud.register('reactor', 'main')
--    ```
--
-- 2. In the cloud host's waitForAny loop, you should wait for cloud messages
--    e.g. for a reactor hosted in the cloud:
--
--    ```
--    function getCloudMessage()
--      data = cloud.pull('reactor', 'main')
--      if data['action'] == 'toggle' then toggleReactor() end
--    end
--    ...
--    parallel.waitForAny(getKey, getTimeout, getCloudMessage)
--    ```
--
-- 3. In the remote device, lookup the host:
--
--    ```
--    reactorId = wireless.lookup('reactor', 'main') -- returns id or nil
--    print('Found reactor at ' .. reactorId)
--    ```
--
-- 4. Then you can send messages to the host from client:
--
--    ```
--    wireless.push({ action: 'toggle' }, 'reactor')
--    ```
--

-- luacheck: globals console cloud cx4

os.unloadAPI('/lib/cx4')
os.loadAPI('/lib/cx4')

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

protocols = {}

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Register a host in the cloud for a protocol
--
-- @tparam {string} protocol
-- @tparam {string} hostname
function register(protocol, hostname)
  local rawHosts = cx4.Get(0)
  local hostsData = textutils.unserialize(rawHosts)

  hostsData[protocol][hostname] = os.getComputerID()
  cx4.Set(0, textutils.serialize(hostsData))
end

--- For hosts to receive messages from cloud
--
-- @tparam {string} protocol
-- @tparam {string} hostname
-- @treturn {table} data
function pull(protocol, hostname)
  local requestData = nil

  -- TODO
  -- http GET from cloud, filter requestsData by protocol, hostname
  -- if a filtered requestData['action'] = '_lookup' then instead of sending to
  -- event loop:
  --   push({ from = OS.getComputerID() }, '_reply', hostname)
  --   return
  -- else
  --   return the requestData to main event loop to do a cloud requested
  --   action

  return requestData
end


--- For clients to push a message to cloud
--
-- @param message
-- @tparam {string} protocol
-- @tparam {string} hostname
-- @treturn {boolean} success
function push(message, protocol, hostname)
  local data = {
    message = message;
    from = os.getComputerID();
  }

  local serializedData = textutils.serialize(data)

  -- http POST to cloud: data.from requests data.action on protocol.hostname

  return false -- http failure
end


--- For clients to find hosts in cloud
--
-- @tparam {string} protocol
-- @tparam {string} hostname
-- @treturn {int} computer ID
function lookup(protocol, hostname)
  push({ action = '_lookup'; }, protocol, hostname)
  reply = pull('_reply', hostname)
  if reply then return reply['from'] end

  -- else timed out
  return nil
end


