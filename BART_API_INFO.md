# BART API Integration

The app now uses the **real BART API** to fetch live train departure data!

## API Details

- **Endpoint**: `https://api.bart.gov/api/etd.aspx`
- **API Key**: `MW9S-E7SL-26DU-VV8V` (Public BART API key)
- **Format**: JSON (`json=y` parameter)
- **Documentation**: https://api.bart.gov/docs/overview/

## Features

✅ **Real-time Departures**: Fetches actual train departure times from BART
✅ **Multiple Stations**: Supports fetching data for multiple stations
✅ **Delay Detection**: Automatically detects and displays service delays
✅ **Platform Grouping**: Groups trains by platform and direction
✅ **Location Integration**: Finds nearest station based on GPS

## Station Abbreviations

The app currently fetches these stations by default:
- `SANL` - San Leandro
- `BAYF` - Bay Fair
- `HAYW` - Hayward
- `EMBR` - Embarcadero
- `MONT` - Montgomery St
- `POWL` - Powell St
- `CIVC` - Civic Center
- `16TH` - 16th St Mission
- `24TH` - 24th St Mission

## Customizing Stations

To change which stations are fetched, edit `TrainService.swift`:

```swift
private var stationAbbreviations = ["SANL", "BAYF", "HAYW", ...]
```

Or enable fetching all stations:

```swift
trainService.fetchAllStations = true
```

## API Response Structure

The BART API returns:
- **Station name and abbreviation**
- **Estimated Time of Departure (ETD)** for each destination
- **Platform information**
- **Direction** (North/South)
- **Line color** and hex color
- **Delay information** (if any)

## Error Handling

The app handles:
- Network errors
- Invalid station abbreviations
- Missing data
- API rate limiting (by limiting concurrent requests)

## Rate Limiting

The app limits to 20 stations to prevent excessive API calls. To fetch more stations, increase the limit in `TrainService.swift`:

```swift
let stationsToProcess = Array(stationsToFetch.prefix(20)) // Change 20 to desired limit
```

## Testing

1. Run the app
2. Wait for data to load (shows "Loading BART departures...")
3. View real-time departure times
4. Pull to refresh to get latest data

## Troubleshooting

### No data showing
- Check internet connection
- Verify station abbreviations are correct
- Check BART API status: https://api.bart.gov/api/bsa.aspx?cmd=bsa&key=MW9S-E7SL-26DU-VV8V&json=y

### Slow loading
- Reduce number of stations in `stationAbbreviations`
- The app fetches stations in parallel but limits to prevent overload

### Errors
- Check that the BART API key is still valid
- Verify station abbreviations exist
- Check network connectivity

## API Documentation

Full BART API documentation: https://api.bart.gov/docs/overview/

Key endpoints:
- **ETD (Estimated Time of Departure)**: `/etd.aspx?cmd=etd&orig=<station>&key=<key>&json=y`
- **Stations List**: `/stn.aspx?cmd=stns&key=<key>&json=y`
- **Service Advisories**: `/bsa.aspx?cmd=bsa&key=<key>&json=y`

