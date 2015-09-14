//
//  XcodeServer+RAC.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 11/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XcodeServerSDK
import ReactiveCocoa

extension XcodeServer {
    
    private func complete<T, E>(sink: Event<T, E> -> (), next: T?, error: E?) {
        if let error = error {
            sendError(sink, error)
        } else {
            precondition(next != nil)
            sendNext(sink, next!)
            sendCompleted(sink)
        }
    }
    
    //MARK: Auth
    
    public func login() -> SignalProducer<Bool, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.login { (success, error) -> () in
                self.complete(sink, next: success, error: error)
            }
        }
    }
    
    public func logout() -> SignalProducer<Bool, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.logout { (success, error) -> () in
                self.complete(sink, next: success, error: error)
            }
        }
    }
    
    public func getUserCanCreateBots() -> SignalProducer<Bool, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getUserCanCreateBots { (canCreateBots, error) -> () in
                self.complete(sink, next: canCreateBots, error: error)
            }
        }
    }
    
    public func verifyXCSUserCanCreateBots() -> SignalProducer<Bool, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.verifyXCSUserCanCreateBots { (success, error) -> () in
                self.complete(sink, next: success, error: error)
            }
        }
    }
    
    //MARK: Bot
    
    public func createBot(botOrder: Bot) -> SignalProducer<CreateBotResponse, NoError> {
        return SignalProducer { (sink, _) -> () in
            self.createBot(botOrder) { (response) -> () in
                self.complete(sink, next: response, error: nil)
            }
        }
    }
    
    public func getBots() -> SignalProducer<[Bot], NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getBots() { (bots, error) -> () in
                self.complete(sink, next: bots, error: error)
            }
        }
    }
    
    public func getBot(botTinyId: String) -> SignalProducer<Bot, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getBot(botTinyId) { (bot, error) -> () in
                self.complete(sink, next: bot, error: error)
            }
        }
    }
    
    public func deleteBot(botId: String, revision: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.deleteBot(botId, revision: revision) { (success, error) -> () in
                self.complete(sink, next: success, error: error)
            }
        }
    }
    
    //MARK: Device
    
    public func getDevices() -> SignalProducer<[Device], NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getDevices() { (devices, error) -> () in
                self.complete(sink, next: devices, error: error)
            }
        }
    }
    
    //MARK: Integration
    
    public func getBotIntegrations(botId: String, query: [String: String]) -> SignalProducer<[Integration], NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getBotIntegrations(botId, query: query) { (integrations, error) -> () in
                self.complete(sink, next: integrations, error: error)
            }
        }
    }
    
    public func postIntegration(botId: String) -> SignalProducer<Integration, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.postIntegration(botId) { (integration, error) -> () in
                self.complete(sink, next: integration, error: error)
            }
        }
    }
    
    public func getIntegrations() -> SignalProducer<[Integration], NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getIntegrations() { (integrations, error) -> () in
                self.complete(sink, next: integrations, error: error)
            }
        }
    }
    
    public func getIntegration(integrationId: String) -> SignalProducer<Integration, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getIntegration(integrationId) { (integration, error) -> () in
                self.complete(sink, next: integration, error: error)
            }
        }
    }
    
    public func cancelIntegration(integrationId: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.cancelIntegration(integrationId) { (success, error) -> () in
                self.complete(sink, next: success, error: error)
            }
        }
    }
    
    public func getIntegrationCommits(integrationId: String) -> SignalProducer<IntegrationCommits, NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getIntegrationCommits(integrationId, completion: { (integrationCommits, error) -> () in
                self.complete(sink, next: integrationCommits, error: error)
            })
        }
    }
    
    //THE compiler seems to be breaking on this one - figure out why
//    public func getIntegrationIssues(integrationId: String) -> SignalProducer<IntegrationIssues, NSError> {
//        return SignalProducer { (sink, _) -> () in
//            self.getIntegrationIssues(integrationId, completion: { (integrationIssues, error) -> () in
//                self.complete(sink, next: integrationIssues, error: error)
//            })
//        }
//    }

    //MARK: Platform
    
    public func getPlatforms() -> SignalProducer<[DevicePlatform], NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getPlatforms() { (platforms, error) -> () in
                self.complete(sink, next: platforms, error: error)
            }
        }
    }
    
    //MARK: Repository
    
    public func getRepositories() -> SignalProducer<[Repository], NSError> {
        return SignalProducer { (sink, _) -> () in
            self.getRepositories() { (repositories, error) -> () in
                self.complete(sink, next: repositories, error: error)
            }
        }
    }
    
    public func createRepository(repository: Repository) -> SignalProducer<CreateRepositoryResponse, NoError> {
        return SignalProducer { (sink, _) -> () in
            self.createRepository(repository) { (response) -> () in
                self.complete(sink, next: response, error: nil)
            }
        }
    }
    
    //MARK: SCM
    
    public func verifyGitCredentialsFromBlueprint(blueprint: SourceControlBlueprint) -> SignalProducer<SCMBranchesResponse, NoError> {
        return SignalProducer { (sink, _) -> () in
            self.verifyGitCredentialsFromBlueprint(blueprint) { (response) -> () in
                self.complete(sink, next: response, error: nil)
            }
        }
    }
}
