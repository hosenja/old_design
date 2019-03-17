//
//  GenericNoDataTagParser.swift
//  mamba
//
//  Created by David Coufal on 7/15/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/**
 A class for generically parsing HLS tags with no data (i.e. `#EXT-X-DISCONTINUITY`)
 
 This is really a no-op class, as the HLSTagDictionary returned from parseTag will always be empty.
 */
public class GenericNoDataTagParser: HLSTagParser {
    
    let tag: HLSTagDescriptor

    public required init(tag: HLSTagDescriptor) {
        self.tag = tag
    }
    
    public func parseTag(fromTagString string: String?) throws -> HLSTagDictionary {
        if let string = string {
            assert(string.count == 0)
        }
        return HLSTagDictionary()
    }
}
