//
//  XcodeServer+Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 30.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - // MARK: - XcodeSever API Routes for Repositories management
extension XcodeServer {
    
    /**
    XCS API call for getting all repositories stored on Xcode Server.
    
    - parameter repositories: Optional array of repositories.
    - parameter error:        Optional error
    */
    public final func getRepositories(completion: (repositories: [Repository]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Repositories, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            guard error == nil else {
                completion(repositories: nil, error: error)
                return
            }
            
            guard let repositoriesBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(repositories: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let repos: [Repository] = XcodeServerArray(repositoriesBody)
            completion(repositories: repos, error: nil)
        }
    }
    
    /**
    Enum with response from creation of repository.
    
    - RepositoryAlreadyExists: Repository with this name already exists on OS X Server.
    - NilResponse:             Self explanatory.
    - CorruptedJSON:           JSON you've used to create repository.
    - WrongStatusCode:         Something wrong with HHTP status.
    - Error:                   There was an error during netwotk activity.
    - Success:                 Repository was successfully created 🎉
    */
    public enum CreateRepositoryResponse {
        case RepositoryAlreadyExists
        case NilResponse
        case CorruptedJSON
        case WrongStatusCode(Int)
        case Error(ErrorType)
        case Success(Repository)
    }
    
    /**
    XCS API call for creating new repository on configured Xcode Server.
    
    - parameter repository: Repository object.
    - parameter repository: Optional object of created repository.
    - parameter error:      Optional error.
    */
    public final func createRepository(repository: Repository, completion: (response: CreateRepositoryResponse) -> ()) {
        let body = repository.dictionarify()
        
        self.sendRequestWithMethod(.POST, endpoint: .Repositories, params: nil, query: nil, body: body) { (response, body, error) -> () in
            if let error = error {
                completion(response: XcodeServer.CreateRepositoryResponse.Error(error))
                return
            }
            
            guard let response = response else {
                completion(response: XcodeServer.CreateRepositoryResponse.NilResponse)
                return
            }
            
            guard let repositoryBody = body as? NSDictionary where response.statusCode == 204 else {
                switch response.statusCode {
                case 200:
                    completion(response: XcodeServer.CreateRepositoryResponse.CorruptedJSON)
                case 409:
                    completion(response: XcodeServer.CreateRepositoryResponse.RepositoryAlreadyExists)
                default:
                    completion(response: XcodeServer.CreateRepositoryResponse.WrongStatusCode(response.statusCode))
                }
                
                return
            }
            
            let repository = Repository(json: repositoryBody)
            completion(response: XcodeServer.CreateRepositoryResponse.Success(repository))
        }
    }
    
}
