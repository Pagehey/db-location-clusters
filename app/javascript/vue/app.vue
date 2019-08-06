<template>
  <div id="app">
    <button @click.prevent="fitToMarkers">Fit to markers</button>
    <span>mapZoom: <strong>{{ mapZoom }} - </strong></span>
    <span>nb of records: <strong>{{ NumberOfRecords }} - </strong></span>
    <span>nb of clusters: <strong>{{ clusters.length }} - </strong></span>
    <span>clusters radius: <strong>{{ clusterRadiusInKm }} - </strong>km</span>
    <input v-model="clusterRadiusInKm" @change="fetchClusters" type="number" step="0.1">
    <button @click="showRecords">Show Records</button>
    <button @click="displayRecords = false">Hide Records</button>
    <GmapMap
      ref="gmap"
      class="gmaps-div"
      map-type-id="terrain"
      :center="center"
      :zoom="mapZoom"
      @zoom_changed="mapZoom = $event"
      @bounds_changed="setBounds"
    >
      <GmapMarker
        v-for="(marker, index) in markers"
        :key="marker.id"
        :position="marker.position"
        :clickable="true"
        :label="{ text: `${marker.reference}` }"
        @dblclick="center = marker.position"
      />
    </GmapMap>
  </div>
</template>

<script>
import * as VueGoogleMaps from 'vue2-google-maps'
import _ from 'lodash'
import axios from 'axios'

export default {
  data: function () {
    return {
      records:         [],
      clusters:        [],
      displayRecords:  false,
      NumberOfRecords: 0,
      center:          { lat: 46.227638, lng: 2.213749 },
      mapZoom:         6,
      mapBounds:       {},
    }
  },
  methods: {
    showRecords() {
      this.fetchRecords()

      this.displayRecords = true
    },
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
    }, 500),
    fetchRecords() {
      axios.get(
        '/records',
        {
          params: {
            // radius: this.clusterRadiusInKm,
            bounds: this.mapBounds
          }
        }
      ).then(response => this.records = response.data.records)
    },
    fetchClusters() {
      axios.get(
        '/clusters',
        {
          params: {
            // radius: this.clusterRadiusInKm,
            bounds: this.mapBounds
          }
        }
      ).then(response => {
        this.clusters = response.data.clusters
        this.NumberOfRecords = response.data.nb_of_records
      })
    }
  },
  computed: {
    clusterRadiusInKm() {
      if (this.mapBounds.nw) {
        const radialLatitude = (this.mapBounds.nw.lat) * Math.PI / 180

        return ((this.mapBounds.nw.lng - this.mapBounds.se.lng) * 111.320 * Math.cos(radialLatitude) / 6)
      }
    },
    markers() {
      if(this.clusters.length > 1000 && !this.displayRecords) return []
      return this.displayRecords ? this.records : this.clusters
    }
  },
  mounted() {
    this.setBounds()
    setTimeout(() => this.fetchClusters(), 500)
  },
  watch: {
    mapBounds() {
      this.fetchClusters()
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
