/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue'
import App from '../vue/app.vue'

import * as VueGoogleMaps from 'vue2-google-maps'
import axios from 'axios'

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



