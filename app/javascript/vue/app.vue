<template>
  <div id="app">
    <button @click.prevent="fitToMarkers">Fit to markers</button>
    <button @click.prevent="displayRecords = !displayRecords">Toggle clusters</button>
    <span>mapZoom: <strong>{{ mapZoom }} - </strong></span>
    <span>mapCenter: <strong>{{ mapCenter.lng }}, {{ mapCenter.lat }}</strong> - </span>
    <span>number of records: <strong>{{ records.length }} - </strong></span>
    <span>number of clusters: <strong>{{ clusters.length }}</strong></span>
    <span>clusters radius: <strong>{{ clusterRadius }}</strong>km</span>
    <GmapMap
      ref="gmap"
      class="gmaps-div"
      map-type-id="terrain"
      :center="center"
      @zoom_changed="updateClusterRadius"
      @center_changed="setMapCenter"
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
      center: {lat: 0, lng: 0},
      displayRecords: false,
      clusterRadius: 10,
      mapZoom: null,
      mapCenter: {lat: 0, lng: 0}
    }
  },
  methods: {
    setMapCenter() {
      this.mapCenter.lat = this.$refs.gmap.$mapObject.getCenter().lat()
      this.mapCenter.lng = this.$refs.gmap.$mapObject.getCenter().lng()
    },
    updateClusterRadius: _.debounce(function(event) { // SHOULD KEEP THIS SYNTAX (VUE INSTANCE NOT AVAILABLE IF NOT)
      this.mapZoom = event
      if(event < 7) {
        this.clusterRadius = 50
      } else if (event >= 18) {
        this.displayRecords = true
      } else if (event >= 13) {
        this.displayRecords = false
        this.clusterRadius = 3
      } else if (event >= 9) {
        this.displayRecords = false
        this.clusterRadius = 5
      } else {
        this.clusterRadius = 10
      }
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
      axios.get('/clusters', { params: { km: this.clusterRadius } }).then(response => this.clusters  = response.data)
    }
  },
  computed: {
    markers() {
      return this.displayRecords ? this.records : this.clusters
    }
  },
  created() {
    axios.get('/records').then(response => this.records = response.data.records)
    this.fetchClusters()
  },
  mounted() {
    setTimeout(() => this.fitToMarkers(), 100)
  },
  watch: {
    clusterRadius() {
      this.fetchClusters()
    }
  }
}
</script>

<style scoped>
.gmaps-div {
  height: 600px;
  width: 100%;
}
</style>
