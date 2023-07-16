import numpy as np
import pandas as pd
import xarray as xr

def findpoint(in_lon, in_lat, gridfile):
    """
    in_lon: longitude of the station
    in_lat: latitude of the station
    gridfile: xarray dataarray that contains coordinates 'longitude' and 'latitude'
    nearest_point: output of the dataarray
    """

    # Compute the distances between each grid point and the specified [lon, lat] location
    distances = ((gridfile.longitude.astype(np.float64) - float(in_lon))**2 +
                (gridfile.latitude.astype(np.float64) - float(in_lat))**2)**0.5
    # Find the minimum distance and corresponding index in the flattened array
    min_distance = distances.min()
    min_index = distances.argmin()

    # Convert the flattened index to 2D index
    # y_index, x_index = np.unravel_index(min_index, gridfile.data_vars[list(gridfile.data_vars.keys())[0]].shape)
    y_index, x_index = np.unravel_index(min_index, gridfile.to_array()[0].shape)

    # Get the value of the DataArray at the nearest grid point
    # nearest_point = gridfile.isel(x=x_index, y=y_index)
    
    return x_index, y_index


def assign_values_to_grid(input_table, gridfile, lon_col, lat_col, value_cols):
    """
    input_table: pandas DataFrame containing columns 'lon_col', 'lat_col', and value_cols
    gridfile: xarray Dataset with coordinates 'longitude' and 'latitude'
    lon_col: column name for longitude in the input_table
    lat_col: column name for latitude in the input_table
    value_cols: list of column names for values in the input_table

    Returns a new xarray Dataset with assigned values to the nearest grid points for each variable.
    """

    # Create an empty dataset with the same coordinate information as gridfile
    new_dataset = xr.Dataset(coords=gridfile.coords)

    # Iterate over each value column
    for col in value_cols:
        # Create a new variable with the specified name
        new_variable = np.zeros_like(gridfile.longitude)  # Initialize with zeros

        # Iterate over each row in the input table
        for _, row in input_table.iterrows():
            lon, lat, value = row[lon_col], row[lat_col], row[col]

            # Find the nearest grid point
            x_index, y_index = findpoint(lon, lat, gridfile)

            # Add the value to the new variable at the nearest grid point
            new_variable[y_index, x_index] += value

        # Assign the new variable to the new dataset using the specified name
        new_dataset[col] = (('y', 'x'), new_variable)
        
        print('Complete ' + f'{col}')

    return new_dataset