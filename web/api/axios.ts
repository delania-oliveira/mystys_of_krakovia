import axios from 'axios'

export const api = axios.create({
  baseURL: 'http://192.168.18.39:2567/api',
})