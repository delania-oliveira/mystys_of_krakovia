import axios from 'axios'

export const api = axios.create({
  baseURL: 'https://playmystysofkrakovia.com.br/api'
})
