import apisauce from 'apisauce'

// import '../../shim.js'
// react-native-crypto
// import crypto from 'crypto'

const BASE_URL = 'http://api.fingi-develop.com'
const CLIENT_ID = '491d83be1463e39c75c2aeda4912119a17f8693e87cf4ee75a58fa032d67f388'
const CLIENT_SECRET = '4c3da6ab221dc68189bfc4e34631f5cf79d1898153161f28cc084cfd6d69ea82'

const callApi = ({
    baseURL = 'http://api.fingi-develop.com',
    apiURL = '',
    apiToken = '',
    apiSecret = '',
    data = '', // json
    type = 'get' // get or post
  }) => {
    // let timestamp = Math.round(Date.now()/1000);
    // let sign = apiURL + timestamp + data
    // let hash = crypto.createHmac('sha1',apiSecret).update(sign).digest('hex')
    // console.log(`${apiURL} | ${apiToken} | ${apiSecret} | ${data} | ${timestamp} | ${sign} | ${hash}`)
    // conn = apisauce.create({
    //   baseURL,
    //   headers: {
    //     'Authorization': `Token token="${apiToken}", timestamp=${timestamp}`,
    //     'X-Fingi-Signature': `${hash}`,
    //     'Content-Type': 'application/json',
    //     'Accepts': 'application/json'
    //   },
    //   timeout: 30000 // 30 sec
    // })

  conn = apisauce.create({
    baseURL,
    headers: {
      'Cache-Control': 'no-cache'
    },
    timeout: 30000 // 30 sec
  })

  return conn
}

// function setHeader(contentType='application/x-www-form-urlencoded',Accepts='application/json'){
//   const header = {
//     'Content-Type': contentType,
//     'Accepts': Accepts
//   }
//   return header
// }

function setHeader () {
  const header = {
    'Cache-Control': 'no-cache',
    'Accept': 'application/json'
  }
  return header
}

const appToken = (obj) => {
  let baseUrl = (obj.siteUrl != null) ? obj.siteUrl : BASE_URL
  let apiUrl = baseUrl + '/oauth/token'
  let clientId = (obj.clientId != null) ? obj.clientId : CLIENT_ID
  let clientSecret = (obj.clientSecret) ? obj.clientSecret : CLIENT_SECRET
  let data = {
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET,
    'grant_type': 'client_credentials'
  }

  console.log(apiUrl)

  const header = setHeader()
  const conn = apisauce.create({
    baseURL: baseUrl,
    headers: header,
    timeout: 30000 // 30 sec
  })

  const getAppToken = () => conn.post(apiUrl, data)
  console.log(getAppToken())

  return {
    getAppToken
  }
}

const appCreateUser = (obj) => {
  let baseUrl = (obj.siteUrl != null) ? obj.siteUrl : BASE_URL
  let apiUrl = baseUrl + '/v4/users?access_token=' + obj.appToken

  console.log(apiUrl)

  const header = setHeader()
  const conn = apisauce.create({
    baseURL: baseUrl,
    headers: header,
    timeout: 30000 // 30 sec
  })

  const getCreateUser = () => conn.post(apiUrl, obj.data)
  console.log(getCreateUser())

  return {
    getCreateUser
  }
}

const userToken = (obj) => {
  let baseUrl = (obj.siteUrl != null) ? obj.siteUrl : BASE_URL
  let apiUrl = baseUrl + '/oauth/token'
  let clientId = (obj.clientId != null) ? obj.clientId : CLIENT_ID
  let clientSecret = (obj.clientSecret) ? obj.clientSecret : CLIENT_SECRET
  let data = {
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET,
    'email': obj.email,
    'grant_type': 'password',
    'password': obj.password
  }
  console.log(apiUrl)
  const header = setHeader()
  const conn = apisauce.create({
    baseURL: baseUrl,
    headers: header,
    timeout: 30000 // 30 sec
  })

  const getUserToken = () => conn.post(apiUrl, data)
  console.log(getUserToken())

  return {
    getUserToken
  }
}

const appUserProfile = (obj) => {
  let baseUrl = (obj.siteUrl != null) ? obj.siteUrl : BASE_URL
  let apiUrl = baseUrl + '/v4/users/profile?access_token=' + obj.userToken

  console.log(apiUrl)

  const header = setHeader()
  const conn = apisauce.create({
    baseURL: baseUrl,
    headers: header,
    timeout: 30000 // 30 sec
  })

  const getProfile = () => conn.get(apiUrl)
  console.log(getProfile())

  return {
    getProfile
  }
}

const createUserWithFacebook = (obj) => {
  let baseUrl = (obj.siteUrl != null) ? obj.siteUrl : BASE_URL
  let apiUrl = baseUrl + '/v4/users?access_token=' + obj.appToken

  console.log(apiUrl)
  const header = setHeader()
  const conn = apisauce.create({
    baseURL: baseUrl,
    headers: header,
    timeout: 30000 // 30 sec
  })

  const getCreateUserWithFacebook = () => conn.post(apiUrl, obj.data)
  console.log(getCreateUserWithFacebook())

  return {
    getCreateUserWithFacebook
  }
}

const userTokenWithFacebook = (obj) => {
  let baseUrl = (obj.siteUrl != null) ? obj.siteUrl : BASE_URL
  let apiUrl = baseUrl + '/oauth/token'
  let clientId = (obj.clientId != null) ? obj.clientId : CLIENT_ID
  let clientSecret = (obj.clientSecret) ? obj.clientSecret : CLIENT_SECRET
  let data = {
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET,
    'grant_type': 'password',
    'provider': 'facebook',
    'uid': obj.uid
  }
  console.log(apiUrl)
  const header = setHeader()
  const conn = apisauce.create({
    baseURL: baseUrl,
    headers: header,
    timeout: 30000 // 30 sec
  })

  const getUserTokenWithFacebook = () => conn.post(apiUrl, data)
  console.log(getUserTokenWithFacebook())

  return {
    getUserTokenWithFacebook
  }
}

export default { appToken, appCreateUser, userToken, appUserProfile, createUserWithFacebook, userTokenWithFacebook }
