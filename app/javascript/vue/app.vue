<template>
  <div id="app">
    <button @click.prevent="fitToMarkers">Fit to markers</button>
    <button @click.prevent="displayRecords = !displayRecords">Toggle clusters</button>
    <span>mapZoom: <strong>{{ mapZoom }} - </strong></span>
    <span>mapCenter: <strong>{{ mapCenter.lng }}, {{ mapCenter.lat }}</strong> - </span>
    <span>nb of records: <strong>{{ records.length }} - </strong></span>
    <span>nb of clusters: <strong>{{ clusters.length }} - </strong></span>
    <span>clusters radius: <strong>{{ clusterRadius }}</strong>km</span>
    <GmapMap
      ref="gmap"
      class="gmaps-div"
      map-type-id="terrain"
      :center="center"
      :zoom="5"
      @zoom_changed="updateClusterRadius"
      @center_changed="setMapCenter"
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
      mapCenter: {lat: 0, lng: 0},
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
    setMapCenter() {
      this.mapCenter.lat = this.$refs.gmap.$mapObject.getCenter().lat()
      this.mapCenter.lng = this.$refs.gmap.$mapObject.getCenter().lng()
    },
    updateClusterRadius: _.debounce(function(event) { // SHOULD KEEP THIS SYNTAX (VUE INSTANCE NOT AVAILABLE IF NOT)
      this.mapZoom = event
      if (event < 15) this.clusterRadius = 15 - event
    }, 500),
    fitToMarkers() {
      let bounds = new google.maps.LatLngBounds();
      this.markers.forEach( marker => {
        let LatLng = new google.maps.LatLng({lat: marker.position.lat, lng: marker.position.lng });

        bounds.extend(LatLng);
      })
      this.$refs.gmap.fitBounds(bounds);
    },
    fetchClusters() {
      axios.get(
        '/clusters',
        { params: {
            radius: this.clusterRadius,
            bounds: this.mapBounds
          }
        }).then(response =>  this.clusters  = response.data)
    },
    fetchRecords() {
      axios.get(
        '/records',
        {
          params: {
            bounds: this.mapBounds
          }
        }).then(response => this.records = response.data.records)
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
    setTimeout(() => {
      this.fetchRecords()
      this.fetchClusters()
    }, 500)
  },
  watch: {
    mapBounds() {
      this.fetchRecords()
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
