class AddSTPointToRecordService
  def call
    Record.where(lonlat: nil).update_all("lonlat = ST_SetSRID(ST_MakePoint(longitude, latitude), 2154)")
  end
end
