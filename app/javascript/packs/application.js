import 'bootstrap'

import '../images/marker-icon.png'

import Vue from 'vue'
import App from '../vue/app.vue'

import * as VueGoogleMaps from 'vue2-google-maps'
import axios              from 'axios'

Vue.use(VueGoogleMaps, {
  load: {
    key: 'AIzaSyB8DSmykcDE-BsMU42Coz805gPyV38nV_I',
    libraries: 'places'
  }
})

axios.defaults.headers.common['Accept'] = 'application/json'
axios.defaults.headers.common['X-CSRF-Token'] = document.getElementsByName('csrf-token')[0].getAttribute('content')

document.addEventListener('DOMContentLoaded', () => {
  const el = document.body.appendChild(document.createElement('vue-app'))
  const app = new Vue({
    el,
    render: h => h(App)
  })
})
