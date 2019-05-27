<template>
  <div id="app">
    <GmapMap
      ref="gmap"
      :center="{lat:10, lng:10}"
      :zoom="7"
      map-type-id="terrain"
      class="gmaps-div"
    >
      <GmapMarker
        :key="index"
        v-for="(m, index) in markers"
        :position="m.position"
        :clickable="true"
        :draggable="true"
        @click="center=m.position"
      />
    </GmapMap>
    <button @click.prevent="fitToMakers">Fit</button>
  </div>
</template>

<script>
import * as VueGoogleMaps from 'vue2-google-maps'
import axios from 'axios'

export default {
  data: function () {
    return {
      markers: [],
      bounds: null
    }
  },
  methods: {
    fitToMakers() {
      let bounds = new google.maps.LatLngBounds();
      this.markers.forEach( marker => {
          let myLatLng = new google.maps.LatLng({lat: marker.latitude, lng: marker.longitude });

          bounds.extend(myLatLng);
      })

      this.$refs.gmap.fitBounds(bounds);
    }
  },
  created() {
    axios.get(
      '/records'
    ).then(response => {
      this.markers = response.data.records
    })
  },
  mounted() {
    setTimeout(() => this.fitToMakers(), 100)
  }
}
</script>

<style scoped>
.gmaps-div {
  height: 600px;
  width: 100%;
}
</style>
