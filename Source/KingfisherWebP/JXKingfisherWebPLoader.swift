//
//  JXKingfisherWebPLoader.swift
//  JXPhotoBrowser
//
//  Created by JiongXing on 2018/10/14.
//

import Foundation
import UIKit
import Kingfisher
import KingfisherWebP

public class JXKingfisherWebPLoader: JXPhotoLoader {
    
    public init() {}
    
    public func imageCached(on imageView: UIImageView, url: URL?) -> UIImage? {
        guard let url = url else {
            return nil
        }
        let cache = KingfisherManager.shared.cache
        let result = cache.imageCachedType(forKey: url.cacheKey, processorIdentifier: "com.yeatse.WebPProcessor")
        switch result {
        case .none:
            return nil
        case .memory:
            return cache.retrieveImageInMemoryCache(forKey: url.cacheKey, options: KingfisherParsedOptionsInfo(options))
        case .disk:
            return cache.retrieveImageInDiskCache(forKey: url.cacheKey, options: KingfisherParsedOptionsInfo(options))
        }
    }
    
    public func setImage(on imageView: UIImageView, url: URL?, placeholder: UIImage?, progressBlock: @escaping (Int64, Int64) -> Void, completionHandler: @escaping () -> Void) {
        imageView.kf.setImage(with: url,
                              placeholder: placeholder,
                              options: options,
                              progressBlock: { (receivedSize, totalSize) in
                                progressBlock(receivedSize, totalSize)
        }) { _ in
            completionHandler()
        }
    }
    
    private var options: KingfisherOptionsInfo {
        return [.cacheOriginalImage,
                .processor(WebPProcessor.default),
                .cacheSerializer(WebPSerializer.default)]
    }
}

private extension Kingfisher.ImageCache {
    func retrieveImageInDiskCache(
        forKey key: String,
        options: KingfisherParsedOptionsInfo) -> UIImage?
    {
        let computedKey = key.computedKey(with: options.processor.identifier)
        do {
            var image: KFCrossPlatformImage?
            if let data = try diskStorage.value(forKey: computedKey, extendingExpiration: options.diskCacheAccessExtendingExpiration) {
                image = options.cacheSerializer.image(with: data, options: options)
            }
            return image
        } catch {
            return nil
        }
    }
}

private extension String {
    func computedKey(with identifier: String) -> String {
        if identifier.isEmpty {
            return self
        } else {
            return appending("@\(identifier)")
        }
    }
}
