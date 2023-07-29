import xarray as xr
import numpy as np
import pandas as pd

import matplotlib.pyplot as plt

import cartopy.crs as ccrs
import cartopy.feature as cfeat
from cartopy.io.shapereader import Reader

from cnmaps import get_adm_maps, clip_quiver_by_map, clip_contours_by_map, draw_map, clip_pcolormesh_by_map

import geopandas as gpd
import shapely.geometry as sgeom
from shapely.prepared import prep

def polygon_to_mask(polygon, x, y):
    '''
    Generate a mask array of points falling into the polygon
    '''
    x = np.atleast_1d(x)
    y = np.atleast_1d(y)
    mask = np.zeros(x.shape, dtype=bool)

    # if each point falls into a polygon, without boundaries
    prepared = prep(polygon)
    for index in np.ndindex(x.shape):
        point = sgeom.Point(x[index], y[index])
        if prepared.contains(point):
            mask[index] = True

    return mask

def pcolor_xiaoshan(lon,lat,data,cmin,cmax,
                    map_polygon,mask_polygon,
                    extent,colorlevel):

    proj=ccrs.PlateCarree()

    fig = plt.figure(figsize=(12,6),dpi=300)
    ax = fig.subplots(1,1,subplot_kw={'projection':proj})
    draw_map(map_polygon, color='k', linewidth=0.8)

    gl = ax.gridlines(
        xlocs=np.arange(-180, 180 + 1, 0.2), ylocs=np.arange(-90, 90 + 1, 0.2),
        draw_labels=True, x_inline=False, y_inline=False,
        linewidth=0, linestyle='--', color='gray')
    gl.top_labels    = False
    gl.right_labels  = False
    gl.rotate_labels = False

    ax.set_extent(extent,ccrs.PlateCarree())

    cs = ax.pcolormesh(lon, lat, data,
                    cmap='Spectral_r',vmin=cmin,vmax=cmax,
                    shading='auto')
    clip_pcolormesh_by_map(cs, mask_polygon)

    cbar=plt.colorbar(cs)
    cbar.set_label('t / yr',size=14)
    cbar.set_ticks(np.arange(cmin,cmax+1,colorlevel))

    max_data = round(data.max().values.item(),2)
    ax.text(x=0.98,y=0.03,s=f'Maximum = {max_data}',size=14,ha='right',
            transform = ax.transAxes)

    return ax

def double_pcolor(lon,lat,data1,data2,
               cmin,cmax,map_polygon,mask_polygon,
               extent,colorlevel,
               sectionname,varstring):
    
    proj = ccrs.PlateCarree()
    
    fig = plt.figure(figsize=(12,5),dpi=300)
    ax = fig.subplots(1,2,subplot_kw={'projection':proj})
    
    for ax_item in ax:
        draw_map(map_polygon, ax=ax_item, color='k', linewidth=0.8)
        ax_item.set_extent(extent,ccrs.PlateCarree())
        # gl = ax_item.gridlines(
        #     xlocs=np.arange(-180, 180 + 1, 0.2), ylocs=np.arange(-90, 90 + 1, 0.2),
        #     draw_labels=True, x_inline=False, y_inline=False,
        #     linewidth=0, linestyle='--', color='gray')
        # gl.top_labels    = False
        # gl.right_labels  = False
        # gl.rotate_labels = False
    
    # local emis
    cs1 = ax[0].pcolormesh(lon, lat, data1,
                    cmap='Spectral_r',vmin=cmin,vmax=cmax,
                    shading='auto')
    clip_pcolormesh_by_map(cs1, mask_polygon,ax=ax[0])
    
    max_data = round(data1.max().values.item(),2)
    sum_data = round(data1.sum().values.item(),2)
    ax[0].text(x=0.98,y=0.03,s=f'Maximum = {max_data}',size=14,ha='right',
            transform = ax[0].transAxes)
    ax[0].text(x=0.02,y=0.03,s=f'Sum = {sum_data}',size=14,ha='left',
            transform = ax[0].transAxes)
    
    ax[0].set_title('Local',size=16)
    
    # MEIC emis
    cs2 = ax[1].pcolormesh(lon, lat, data2,
                    cmap='Spectral_r',vmin=cmin,vmax=cmax,
                    shading='auto')
    clip_pcolormesh_by_map(cs2, mask_polygon,ax=ax[1])
    
    max_data = round(data2.max().values.item(),2)
    sum_data = round(data2.sum().values.item(),2)
    ax[1].text(x=0.98,y=0.03,s=f'Maximum = {max_data}',size=14,ha='right',
            transform = ax[1].transAxes)
    ax[1].text(x=0.02,y=0.03,s=f'Sum = {sum_data}',size=14,ha='left',
            transform = ax[1].transAxes)
    
    ax[1].set_title('MEIC',size=16)
    
    # Difference
    # cs3 = ax[2].pcolormesh(lon, lat, data1-data2,
    #                 cmap='Spectral_r',vmin=cmin,vmax=cmax,
    #                 shading='auto')
    # clip_pcolormesh_by_map(cs3, mask_polygon)
    
    fig.subplots_adjust(right=0.9,wspace=0.05)
    position= fig.add_axes([0.92,0.16,0.015,0.674])
    cbar=fig.colorbar(cs1,cax=position)
    cbar.set_ticks(np.arange(0,cmax+1,colorlevel))
    cbar.set_label('t / yr')
    
    plt.suptitle(sectionname,size=16,weight='bold')
    plt.text(-0.05,0.5,varstring,size=14,ha='center',va='center',transform=ax[0].transAxes,rotation=90)
    
    plt.show()
    return None