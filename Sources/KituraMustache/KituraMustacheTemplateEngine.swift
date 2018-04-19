/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import KituraTemplateEngine
import Mustache
import Foundation

// MustacheTemplateEngineError for Error handling.
// unableToCastJSONToDict - Thrown when unable to cast 'json' value to a [String: Any]
// unableToEncodeValue(value: Encodable) - Thrown when unable to encode the Encodable value provided to data.
// unableToIntialiseTemplateWithFilePath(path: String) - Thrown when the inialisation of Template() fails.
// unableToRenderContext(context: [String: Any]) - Thrown when GRMustache fails to render the context with the given template.
public enum MustacheTemplateEngineError: Swift.Error {
    case unableToCastJSONToDict
    case unableToEncodeValue(value: Encodable)
    case unableToIntialiseTemplateWithFilePath(path: String)
    case unableToRenderContext(context: [String: Any])
}

public class MustacheTemplateEngine: TemplateEngine {
    public var fileExtension: String { return "mustache" }
    public init() {}
    
    public func render<T: Encodable>(filePath: String, with value: T, forKey key: String?,
                                   options: RenderingOptions, templateName: String) throws -> String {
        
        var data = Data()
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw MustacheTemplateEngineError.unableToEncodeValue(value: value)
        }
        guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw MustacheTemplateEngineError.unableToCastJSONToDict
        }
        var context: [String: Any]
        if let contextKey = key {
            context = [contextKey: json]
        } else {
            context = json
        }
        
        return try render(filePath: filePath, context: context)
        
    }
    
    public func render(filePath: String, context: [String: Any]) throws -> String {
        let template: Template
        do {
            template = try Template(path: filePath)
        } catch {
            throw MustacheTemplateEngineError.unableToIntialiseTemplateWithFilePath(path: filePath)
        }
        do {
            let result = try template.render(with: Box(context))
            return result
        } catch {
            throw MustacheTemplateEngineError.unableToRenderContext(context: context)
        }
    }
}
