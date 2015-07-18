//
//  XcodeServer+SCM.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01.07.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Source Control Management
extension XcodeServer {
    
    /**
    Verifies that the blueprint contains valid Git credentials and that the blueprint contains a valid
    server certificate fingerprint for client <-> XCS communication.
    
    - parameter blueprint:  SC blueprint which should be verified.
    - parameter response:   SCM response.
    */
    public final func verifyGitCredentialsFromBlueprint(blueprint: SourceControlBlueprint, completion: (response: SCMBranchesResponse) -> ()) {
        
        //just a proxy with a more explicit name
        self.postSCMBranchesWithBlueprint(blueprint, completion: completion)
    }
    
    // MARK: Helpers
    
    /**
    Enum for Source Control Management responses.
    
    - Error:                            Error.
    - SSHFingerprintFailedToVerify:     Couldn't verify SSH fingerprint.
    - Success:                          Verification was successful.
    */
    public enum SCMBranchesResponse {
        case Error(ErrorType)
        case SSHFingerprintFailedToVerify(fingerprint: String, repository: String)
        
        //the valid blueprint will have the right certificateFingerprint
        case Success(branches: [(name: String, isPrimary: Bool)], validBlueprint: SourceControlBlueprint)
    }
    
    final func postSCMBranchesWithBlueprint(blueprint: SourceControlBlueprint, completion: (response: SCMBranchesResponse) -> ()) {
        
        let blueprintDict = blueprint.dictionarifyRemoteAndCredentials()
        
        self.sendRequestWithMethod(.POST, endpoint: .SCM_Branches, params: nil, query: nil, body: blueprintDict) { (response, body, error) -> () in
            
            if let error = error {
                completion(response: XcodeServer.SCMBranchesResponse.Error(error))
                return
            }
            
            guard let responseObject = body as? NSDictionary else {
                let e = Error.withInfo("Wrong body: \(body)")
                completion(response: XcodeServer.SCMBranchesResponse.Error(e))
                return
            }
            
            //take the primary repository's key. XCS officially supports multiple checkouts (submodules)
            let primaryRepoId = blueprint.projectWCCIdentifier
            
            //communication worked, now let's see what we got
            //check for errors first
            if
                let repoErrors = responseObject["repositoryErrors"] as? [NSDictionary],
                let repoErrorWrap = repoErrors.findFirst({ $0["repository"] as? String == primaryRepoId }),
                let repoError = repoErrorWrap["error"] as? NSDictionary
                where repoErrors.count > 0 {
                    
                    if let code = repoError["code"] as? Int {
                        
                        //ok, we got an error. do we recognize it?
                        switch code {
                        case -1004:
                            //ok, this is failed fingerprint validation
                            //pull out the new fingerprint and complete.
                            if let fingerprint = repoError["fingerprint"] as? String {
                                
                                //optionally offer to resolve this issue by adopting the new fingerprint
                                if self.config.automaticallyTrustSelfSignedCertificates {
                                    
                                    blueprint.certificateFingerprint = fingerprint
                                    self.postSCMBranchesWithBlueprint(blueprint, completion: completion)
                                    return
                                    
                                } else {
                                    completion(response: XcodeServer.SCMBranchesResponse.SSHFingerprintFailedToVerify(fingerprint: fingerprint, repository: primaryRepoId))
                                }
                                
                            } else {
                                completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("No fingerprint provided in error \(repoError)")))
                            }
                            
                        default:
                            completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("Unrecognized error: \(repoError)")))
                        }
                    } else {
                        completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("No code provided in error \(repoError)")))
                    }
                    return
            }
            
            //cool, no errors. now try to parse branches!
            guard
                let branchesAllRepos = responseObject["branches"] as? NSDictionary,
                let branches = branchesAllRepos[primaryRepoId] as? NSArray else {
                    
                    completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("No branches provided for our primary repo id: \(primaryRepoId).")))
                    return
            }
            
            //cool, we gots ourselves some branches, let's parse 'em
            let parsedBranches = branches.map({ (name: $0["name"] as! String, isPrimary: $0["primary"] as! Bool) })
            completion(response: XcodeServer.SCMBranchesResponse.Success(branches: parsedBranches, validBlueprint: blueprint))
        }
    }
    
}