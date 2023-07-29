import numpy as np
import xarray as xr
import geopandas as gpd
import shapely.geometry as sgeom
from shapely.prepared import prep

def polygon_to_mask(polygon, x, y):
    """
    Generate a mask array indicating points falling within the polygon.

    Args:
        polygon (shapely.geometry.Polygon): Polygon object defining the boundary.
        x (array-like): Array of x coordinates.
        y (array-like): Array of y coordinates.

    Returns:
        mask (numpy array): Boolean mask array indicating points within the polygon.
    """

    # Convert x and y to NumPy arrays
    x = np.asarray(x)
    y = np.asarray(y)

    # Create an empty mask array
    mask = np.zeros_like(x, dtype=bool)

    # Check if each point falls within the polygon
    prepared = prep(polygon)
    for index in np.ndindex(x.shape):
        point = sgeom.Point(x[index], y[index])
        if prepared.contains(point):
            mask[index] = True

    return mask

def merge_datasets(mask, dataset_A, dataset_B):
    """
    Merge two datasets based on a mask.

    Args:
        mask (numpy array or xarray.Dataarray): Boolean mask array indicating the range of points.
        dataset_A (xarray.Dataset): First dataset to merge.
        dataset_B (xarray.Dataset): Second dataset to merge.

    Returns:
        merged_dataset (xarray.Dataset): Merged dataset.
    """

    # Check if the datasets are xarray datasets
    if not isinstance(dataset_A, xr.Dataset) or not isinstance(dataset_B, xr.Dataset):
        raise TypeError("Datasets should be xarray datasets.")

    merged_dataset = xr.Dataset()

    for var_name, var_A in dataset_A.data_vars.items():
        var_B = dataset_B[var_name]

        # Mask the grids within the range with data from dataset A
        var_A_masked = var_A.where(mask)

        # Mask the grids outside the range with data from dataset B
        var_B_masked = var_B.where(~mask)

        # Merge data from dataset A and B based on the mask
        merged_var = xr.where(mask, var_A_masked, var_B_masked)
        
        # confirm the sequence
        merged_var = merged_var.transpose('TSTEP', 'LAY', 'ROW', 'COL')
        
        # Add the merged variable to the new dataset
        merged_dataset[var_name] = merged_var

    return merged_dataset