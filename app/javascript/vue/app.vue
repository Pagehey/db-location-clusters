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
      :zoom="7"
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
      clusterRadius: 20,
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
            lng: bounds.ga.l + 0.005,
            lat: bounds.na.l + 0.05
          },
          se: {
            lng: bounds.ga.j - 0.005,
            lat: bounds.na.j - 0.05
          }
        }
      }
    }, 1000),
    updateClusterRadius: _.debounce(function(event) { // SHOULD KEEP THIS SYNTAX (VUE INSTANCE NOT AVAILABLE IF NOT)
      this.mapZoom = event
      if (event < 15) this.clusterRadius = 15 - event
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
          this.records = response.data.records
          this.clusters  = response.data.clusters
        })
    }
  },
  computed: {
    markers() {
      return this.displayRecords ? this.records : this.clusters
    },
    displayRecords() {
      return this.mapZoom >= 15
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
