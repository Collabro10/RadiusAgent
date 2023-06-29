//
//  FacilitiesInteractor.swift
//  Radius Assignemnt
//
//  Created by Tushar Tiwary on 29/06/23.
//

import UIKit

protocol FacilitiesPresentable: FacilitiesInterface, FacilitiesInteractable {
    var interactor: FacilitiesInteractable! { get set }

}

final class FacilitiesInteractor: FacilitiesInteractable {
    
    init() {
        
    }
    
    func fetchFacilities(apiURL: String, completion: @escaping (Result<Facilities, Error>) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty response data"])))
                return
            }
            
            do {
                let cardLinks = try JSONDecoder().decode(Facilities.self, from: data)
                completion(.success(cardLinks))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
