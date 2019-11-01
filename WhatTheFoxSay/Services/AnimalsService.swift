//
//  AuthServices.swift
//  EasyFit
//
//  Created by Stasiuk Yaroslav on 25.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

struct AnimalsService {
    private static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    private static func downloadImage(from url: URL) {
        print("[AnimalsService] downloadImage():", url)
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                let image = UIImage(data: data)
                
            }
        }
    }
    // 
    private static func getMockedJson(completion: @escaping(Result<JSON, Error>) -> ()) {
        DispatchQueue.global().async(qos: .background) {
            guard let path = Bundle.main.path(forResource: "Animals", ofType: "json") else {
                completion(.failure(DataError.connection))
                return
            }
            
            let url = URL(fileURLWithPath: path)

            do {
                let data = try Data(contentsOf: url)
                let json = try JSON(data: data)
                completion(.success(json))
            } catch {
                completion(.failure(DataError.parse))
            }
        }
    }
    
    private static func isAnimalAlreadyCreated(id: UUID) -> Bool{
        print("[AnimalsService] isAnimalCreated()", id.uuidString)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Animal")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        let appDelegate = AppDelegate.appDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        var results: [Any] = []
        do {
            results = try managedContext.fetch(fetchRequest)
        } catch {
            print("[AnimalsService] isAnimalCreated error:", error)
        }
        
        return results.count != 0
    }
    
    private static func createNewAnimal(json: JSON) {
        print("[AnimalsService] createNewAnimal()")
        let appDelegate = AppDelegate.appDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let uuid = UUID.init(uuidString: json["id"].string!) else {
            print("[AnimalsService] createNewAnimal(): non-valid UUID:", json["id"].string!)
            return
        }
        
        if self.isAnimalAlreadyCreated(id: uuid) {
            print("[AnimalsService] createNewAnimal(): already created ID:", uuid.uuidString)
            return
        }
        
        let animalEntity = NSEntityDescription.entity(forEntityName: "Animal", in: managedContext)!
        let animal = NSManagedObject(entity: animalEntity, insertInto: managedContext)
        
        do {
            let name = json["name"].string!
            let avatarURI = NSURL(string: json["avatarURI"].string!)
            let description = json["description"].string!
            let imagesURI = json["imagesURI"].rawString()
            
            animal.setValue(name, forKey: "name")
            animal.setValue(uuid, forKey: "id")
            animal.setValue(avatarURI, forKey: "avatarURI")
            animal.setValue(description, forKey: "a_description")
            animal.setValue(imagesURI, forKey: "imagesURI")

            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private static func saveAnimals(animalsJSON: Array<JSON>) {
        for animalJSON in animalsJSON {
            createNewAnimal(json: animalJSON)
        }
    }
    
    private static func retriveAnimals() -> Array<Animal> {
        print("[AnimalsService] retriveAnimals()")
        var animals: Array<Animal> = []
       //As we know that container is set up in the AppDelegates so we need to refer that container.
        let appDelegate = AppDelegate.appDelegate
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Animal")

        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                guard let uuid = (data.value(forKey: "id") as? UUID)?.uuidString else { continue }
                guard let name = data.value(forKey: "name") as? String else { continue }
                guard let avatarURI = data.value(forKey: "avatarURI") as? NSURL else { continue }
                guard let description = data.value(forKey: "a_description") as? String else { continue }
                guard let imagesURIString = data.value(forKey: "imagesURI") as? String else { continue }
                let imagesURI = JSON(parseJSON: imagesURIString).arrayValue.map { $0.stringValue}
                print("123:", imagesURIString)
                print("imagesURI", imagesURI)
                let animal = Animal(id: uuid, name: name, avatarURI: avatarURI, description: description, imagesURI: imagesURI)
                animals.append(animal)
            }
            
        } catch {
            print("Failed", error)
        }
        return animals
    }

    static func getAnimals(completion: @escaping (Result<Array<Animal>, Error>) -> ()) {
        #if DEBUG
        self.deleteAllAnimals()
        #endif
        print("[AnimalsService] getAnimals()")
        DispatchQueue.global().async(qos: .background) {
            getMockedJson() { (result) in
                switch (result) {
                case .success(let animalsJSON):
                    // TODO: Not throwable for now
                    do {
                        saveAnimals(animalsJSON: animalsJSON["animals"].arrayValue)
                        let animals = retriveAnimals()
                        completion(.success(animals))
                    } catch {
                        completion(.failure(DataError.parse))
                    }
                case .failure(let err):
                    completion(.failure(err))
                }
            }
        }
    }
    
    private static func deleteAllAnimals() {
        let appDelegate = AppDelegate.appDelegate
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Animal")
    
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                managedContext.delete(data)
            }
            try managedContext.save()
        } catch {
            print("Failed")
        }
        
    }
}
