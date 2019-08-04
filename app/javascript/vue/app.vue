<template>
  <div id="app">
    <button @click.prevent="fitToMarkers">Fit to markers</button>
    <span>mapZoom: <strong>{{ mapZoom }} - </strong></span>
    <span>nb of records: <strong>{{ records.length }} - </strong></span>
    <span>nb of clusters: <strong>{{ clusters.length }} - </strong></span>
    <span>clusters radius: <strong>{{ clusterRadius }} - </strong>km</span>
    <input v-model="clusterRadius" @change="fetchRecords" type="number">
    <GmapMap
      ref="gmap"
      class="gmaps-div"
      map-type-id="terrain"
      :center="center"
      :zoom="mapZoom"
      @zoom_changed="updateClusterRadius"
      @bounds_changed="setBounds"
    >
      <GmapMarker
        v-for="(marker, index) in markers"
        :key="marker.id"
        :position="marker.position"
        :clickable="true"
        :label="{ text: `${marker.name}` }"
        @dblclick="center = marker.position"
      /></GmapMap>
  </div>
</template>

<script>
import * as VueGoogleMaps from 'vue2-google-maps'
import _ from 'lodash'
import axios from 'axios'

export default {
  data: function () {
    return {
      records: [],
      clusters: [],
      center: {lat: 46.227638, lng: 2.213749},
      clusterRadius: 25,
      mapZoom: 5,
      mapBounds: {}
    }
  },
  methods: {
    setBounds: _.debounce(function(event) {
      const bounds = this.$refs.gmap.$mapObject.getBounds()
      if(bounds) {
        this.mapBounds = {
          nw: {
            lng: bounds.ga.l,
            lat: bounds.na.l
          },
          se: {
            lng: bounds.ga.j,
            lat: bounds.na.j
          }
        }
      }
    }, 1000),
    updateClusterRadius: _.debounce(function(event) { // SHOULD KEEP THIS SYNTAX (VUE INSTANCE NOT AVAILABLE IF NOT)
      this.mapZoom = event
      // if (event < 9) {
      //   this.clusterRadius = 25
      // } else if (event < 15) {
      //   this.clusterRadius = 15 - event
      // }
      // this.clusterRadius =  - (245 / 150) * event + (199 / 6) // 5:25/20:0.5
      this.clusterRadius =  (- 1.9 * event + 34.5) // 5:25.18:0.3
    }, 500),
    fetchRecords() {
      axios.get(
        '/records',
        {
          params: {
            radius: this.clusterRadius,
            bounds: this.mapBounds
          }
        }).then(response => {
          this.records  = response.data.records
          this.clusters = response.data.clusters
        })
    }
  },
  computed: {
    markers() {
      return this.displayRecords ? this.records : this.clusters
    },
    displayRecords() {
      // return this.mapZoom >= 15
      return false
    }
  },
  mounted() {
    setTimeout(() => this.fetchRecords(), 500)
  },
  watch: {
    mapBounds() {
      this.fetchRecords()
    }
  }
}
</script>

<style scoped>
.gmaps-div {
  width: 100%;
  height: calc(100vh - 100px);
}
</style>
