package top.kikt.imagescanner.core

import android.content.Context
import android.os.Build
import top.kikt.imagescanner.core.cache.AndroidQCache
import top.kikt.imagescanner.core.entity.AssetEntity
import top.kikt.imagescanner.core.entity.GalleryEntity
import top.kikt.imagescanner.core.utils.DBUtils
import top.kikt.imagescanner.old.ResultHandler
import top.kikt.imagescanner.thumb.ThumbnailUtil
import top.kikt.imagescanner.util.LogUtils
import java.io.File

/// create 2019-09-05 by cai
/// Do some business logic assembly
class PhotoManager(private val context: Context) {

    companion object {
        const val ALL_ID = "isAll"
    }

    val androidQCache = AndroidQCache(context)

    fun getGalleryList(type: Int, timeStamp: Long, hasAll: Boolean): List<GalleryEntity> {
        val fromDb = DBUtils.getGalleryList(context, type, timeStamp)

        if (!hasAll) {
            return fromDb
        }

        // make is all to the gallery list
        val entity = fromDb.run {
            var count = 0
            for (item in this) {
                count += item.length
            }
            GalleryEntity(ALL_ID, "Recent", count, type, true)
        }

        return listOf(entity) + fromDb
    }

    fun getAssetList(galleryId: String, page: Int, pageCount: Int, typeInt: Int = 0, timeStamp: Long): List<AssetEntity> {
        val gId = if (galleryId == ALL_ID) "" else galleryId
        return DBUtils.getAssetFromGalleryId(context, gId, page, pageCount, typeInt, timeStamp)
    }

    fun getThumb(id: String, width: Int, height: Int, resultHandler: ResultHandler) {
        val asset = DBUtils.getAssetEntity(context, id)
        if (asset == null) {
            resultHandler.replyError("The asset not found!")
            return
        }
        ThumbnailUtil.getThumbnailByGlide(context, asset.path, width, height, resultHandler.result)
    }

    fun getOriginBytes(id: String, resultHandler: ResultHandler) {
        val asset = DBUtils.getAssetEntity(context, id)

        if (asset == null) {
            resultHandler.replyError("The asset not found")
            return
        }

        val byteArray = File(asset.path).readBytes()
        resultHandler.reply(byteArray)
    }

    fun clearCache() {
        DBUtils.clearCache()
    }

    fun getPathEntity(id: String, type: Int, timestamp: Long): GalleryEntity? {
        if (id == ALL_ID) {
            val allGalleryList = DBUtils.getGalleryList(context, type, timestamp)
            return if (allGalleryList.isEmpty()) {
                null
            } else {
                // make is all to the gallery list
                allGalleryList.run {
                    var count = 0
                    for (item in this) {
                        count += item.length
                    }
                    GalleryEntity(ALL_ID, "Recent", count, type, true)
                }
            }
        }
        return DBUtils.getGalleryEntity(context, id, type, timestamp)
    }

    fun getFile(id: String, resultHandler: ResultHandler) {
        if (Build.VERSION.SDK_INT <= 28) {
            resultHandler.reply(id)
            return
        } else {
            val assetEntity = DBUtils.getAssetEntity(context, id)
            if (assetEntity == null) {
                resultHandler.reply(null)
                return
            }
            LogUtils.isLog = true
            LogUtils.info("flutter: ${assetEntity.mimeType}")
//            androidQCache.getCacheFile(id, ".jpg")
        }
    }

}