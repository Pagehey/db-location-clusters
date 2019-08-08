<template>
  <div id="app">
    <div class="m-3">
      <span class="mx-2">zoom: <strong>{{ zoom }}</strong></span>
      <span class="mx-2">number of records: <strong>{{ numberOfRecords }}</strong></span>
      <span class="mx-2">number of clusters: <strong>{{ clusters.length }}</strong></span>
      <span class="mx-2">clusters size: <strong>{{ clusterSizeInKm || 0 }}</strong> <i>km</i></span>
    </div>

    <GmapMap
      ref="gmap"
      class="gmaps-div"
      map-type-id="terrain"
      :center="center"
      :zoom="zoom"
      @zoom_changed="zoom = $event"
      @bounds_changed="setBounds"
    >
      <GmapMarker
        v-for="(marker) in markers"
        :key="marker.id"
        :position="marker.position"
        :clickable="true"
        :label="{ text: `${marker.reference || marker.number_of_records}` }"
        :icon="'http://icons.iconarchive.com/icons/custom-icon-design/flatastic-6/72/Circle-icon.png'"
        @dblclick="center = marker.position"
      />
    </GmapMap>

  </div>
</template>

<script>
import * as VueGoogleMaps from 'vue2-google-maps'
import _                  from 'lodash'
import axios              from 'axios'

export default {
  data() {
    return {
      records:   [],
      clusters:  [],
      center:    { lat: 46.227638, lng: 2.213749 },
      mapBounds: {},
      zoom:      6
    }
  },
  methods: {
    setBounds: _.debounce(function(event) {
      this.mapBounds = {
        nw: { lng: event.ga.l, lat: event.na.l },
        se: { lng: event.ga.j, lat: event.na.j }
      }
    }, 500),
    fetchRecords() {
      return axios.get('/records', {params: {bounds: this.mapBounds}}).then(response => this.records = response.data.records)
    },
    fetchClusters() {
      return axios.get('/clusters', {params: {bounds: this.mapBounds}}).then(response => this.clusters = response.data.clusters)
    }
  },
  computed: {
    displayRecords() {
      return _.max(_.map(this.clusters, 'number_of_records')) <= 3
    },
    markers() {
      return this.displayRecords ? this.records : this.clusters
    },
    // ONLY FOR INFORMATION, NOT NEEDED TO MAKE THE QUERY WORKS ################
    numberOfRecords() {
      return _.sumBy(this.clusters, 'number_of_records')
    },
    clusterSizeInKm() {
      if (this.mapBounds.nw) {
        const radialLatitude = (this.mapBounds.nw.lat) * Math.PI / 180

        return ((this.mapBounds.nw.lng - this.mapBounds.se.lng) * 111.320 * Math.cos(radialLatitude) / 6).toFixed(3)
      }
    },
    // #########################################################################
  },
  watch: {
    mapBounds() { // FETCH THE CLUSTERS EACH TIME THE BOUNDS CHANGE (zoom and move the map) and records if needed
      this.fetchClusters().then(() => { if(this.displayRecords) this.fetchRecords() })
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
