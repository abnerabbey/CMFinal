//
//  AhorcadoViewController.swift
//  FinalCM
//
//  Created by Antonio Santiago on 10/27/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import UIKit

class AhorcadoViewController: UIViewController {
    
    // MARK: ATTRIBUTES
    var category: String?
    var word: String?
    
    var wordHidden: [UIImageView] = []
    var breakSpaces: [UIImageView] = []
    // var firstImage: UIImageView!
    
    let ahorcadoXML = AhorcadoXMLParser()
    
    var errors = 0
    var rightGuesses = 0
    
    // MARK: OUTLETS
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet var letterOutlet: [UIButton]!
    @IBOutlet var hangman: [UIImageView]!
    

    // MARK: METHODS
    
    func fetchWords() {
        
        // Getting text for wordLabel and categoryLabel from Server
        if let strCat = Optional(ahorcadoXML.categoria) {
            print("Category found from XML is: \(String(strCat!)) and its length is: \(String(strCat!).characters.count)")
            category = ahorcadoXML.categoria!
            categoryLabel.text = category
            
        } else {
            print("No category was found!")
        }
        
        if let strWord = Optional(ahorcadoXML.palabra) {
            print("Word found from XML length is: \(ahorcadoXML.palabra!) and its length is: \(String(strWord!).characters.count)")
            word = ahorcadoXML.palabra!
            // wordLabel.text = word
        } else {
            print("No word was found!")
        }
        
        /*if let catOp = category {
            category = String(ahorcadoXML.elements.objectForKey("CATEGORIA")!)
            categoryLabel.text = catOp
        }
        else {
            print("category value is nil")
        }
        if let wordOp = word {
            word = String(ahorcadoXML.elements.objectForKey("PALABRA")!)
            wordLabel.text = wordOp
        }
        else {
            print("word value is nil")
        }
        */
    }

    func displayWordHidden(word: String) {
        
        if Optional(word) != nil {
            var i=0
            // var posX: CGFloat = self.view.frame.width/CGFloat((word.characters.count)+1)
            
            var imageRatio:CGFloat
            let letterWidth:CGFloat = self.view.frame.size.width*0.05
            var letterHeight:CGFloat
            
            var breakSpaceRatio:CGFloat
            let breakSpaceWidth:CGFloat = self.view.frame.size.width*0.05
            var breakSpaceHeight:CGFloat
            
            let posY: CGFloat = self.view.frame.height/2.25
            let spacingX: CGFloat = CGFloat((word.characters.count)) * (self.view.frame.width*0.01)
            var posX: CGFloat = (self.view.frame.width/2)-((letterWidth*CGFloat(word.characters.count))/2) - spacingX/2
            
            // wordHidden = word.characters.count
            
            // Display Word Hidden and Break Spaces
            for letters in word.characters {
                // print("Cycle will be repeated \(word.characters.count) times")
                print("\(letters).png")
                print("Position in x is: \(posX)")
                // Preparing size and position parameters for the Image View
                if(letters != " ") {
                    if(letters == "Ñ") {
                        print("-----------ALERTA------ TOCÓ UNA \(letters)")
                        wordHidden.append(UIImageView(image: UIImage(named: "NI")))
                        breakSpaces.append(UIImageView(image: UIImage(named: "_")))
                        // wordHidden[i] = UIImageView(image: UIImage(named: "\ni"))
                        // firstImage = UIImageView(image: UIImage(named: "\ni"))
                    } else {
                        wordHidden.append(UIImageView(image: UIImage(named: "\(letters)")))
                        breakSpaces.append(UIImageView(image: UIImage(named: "_")))
                        // wordHidden[i] = UIImageView(image: UIImage(named: "\(letters)"))
                        // firstImage = UIImageView(image: UIImage(named: "\(letters)"))
                        print("About to print letter \(letters)")
                    }
                } else {        // In case there are no letters or no `ñ`
                    wordHidden.append(UIImageView(image: UIImage(named: "break")))
                    breakSpaces.append(UIImageView(image: UIImage(named: "break")))
                    // wordHidden[i] = UIImageView(image: UIImage(named: "break"))
                    // firstImage = UIImageView(image: UIImage(named: "break"))
                }
                imageRatio = wordHidden[i].frame.size.width/wordHidden[i].frame.size.height
                breakSpaceRatio = breakSpaces[i].frame.size.width/breakSpaces[i].frame.size.height
                breakSpaceHeight = breakSpaceWidth/breakSpaceRatio
                // imageRatio = firstImage.frame.size.width/firstImage.frame.size.height
                letterHeight = letterWidth/imageRatio
                print("POSITION AND SIZE VALUES ARE: \nimageRatio=\(imageRatio)\nletterWidth= \(letterWidth)\nletterHeight:\(letterHeight)")
                // Presenting Image Views
                breakSpaces[i].frame = CGRect(x: posX, y: posY+letterHeight+self.view.frame.width*0.001, width: breakSpaceWidth, height: breakSpaceHeight)
                wordHidden[i].frame = CGRect(x: posX, y: posY, width: letterWidth, height: letterHeight)
                // firstImage.frame = CGRect(x: posX, y: posY, width: letterWidth, height: letterHeight)
                // firstImage.hidden = true                 // Uncomment when word is well positioned
                wordHidden[i].hidden = true
                self.view.addSubview(breakSpaces[i])
                self.view.addSubview(wordHidden[i])
                // self.view.addSubview(firstImage)
                // images.append(UIImageView(image: UIImage(named: "\(letters)")))
                // self.view.addSubview(images[i])
                posX += (self.view.frame.width*0.01+letterWidth)
                i++
            }
        } else {
            print("No connection")
        }
    }
    
    func unhideLetter(letter: String) {

        var i: Int = 0
        var coincidence = false
        print("Will work with the word \(word!)")
        print("You have made \(errors) mistakes")
        for letters in word!.uppercaseString.characters {
            print("About to compare the letter '\(letter)' with the letter '\(letters)'")
            if letter == String(letters) {
                print("Se encontró la letra \(letters) en el índice \(i)")
                wordHidden[i].hidden = false
                coincidence = true
                rightGuesses++
            } else {
                print("NO se encontró la letra \(letters)")
            }
            i++
        }
        if !coincidence {
            hangman[errors].hidden = false
            errors++
        }
        
        if errors >= 6 {
            print("YOU'VE LOST!")
            gameEnded("¡Has perdido! :(", message: "La respuesta es \(word!)\nPresiona OK para iniciar un nuevo juego")
        }
        
        if rightGuesses >= word?.characters.count {
            print("YOU'VE WON!!!!!!!!!! :D")
            gameEnded("¡Has ganado! :D", message: "Presiona OK para iniciar un nuevo juego")
        }
        
    }
    
    // MARK: END OF THE GAME
    
    func gameEnded(title: String, message: String) {
        let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.viewDidLoad()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resetView() {
        // Reset all letters to enabled
        for buttons in letterOutlet {
            buttons.enabled = true
        }
        
        for letters in wordHidden {
            letters.removeFromSuperview()
        }
        
        for spaces in breakSpaces {
            spaces.removeFromSuperview()
        }
        
        for pieces in hangman {
            pieces.hidden = true
        }
        
        wordHidden.removeAll()
        errors = 0
        rightGuesses = 0
    }
    
    // MARK: METHODS
    
    override func viewDidLoad() {
        
        resetView()
        if ahorcadoXML.verifyValues() {
            super.viewDidLoad()
            self.navigationItem.title = "Ahorcado"
            // displayWordHidden("ANIMALESMANDRIL".uppercaseString)
            fetchWords()
            if word != nil {
                displayWordHidden(word!.uppercaseString)
            } else {
                print("No word found")
            }
        } else {
            print("Connection to the server could not be established.")
            for letters in letterOutlet {
                letters.enabled = false
            }
            let noConnectionAlert = UIAlertController(title: "Conexión no establecida", message: "El servidor no está disponible o no tienes conexión a Internet. Intenta más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            noConnectionAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction: UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(noConnectionAlert, animated: true, completion: nil)
            // Cambiar este print, debe mostrar una alerta en la cual se diga que no se pudo establecer la conexión
        }
    

    }
    
    // MARK: ACTIONS
    
    @IBAction func buttonPressed(sender: UIButton) {
        switch (sender.tag) {
        case 0:
            unhideLetter("A")
            letterOutlet[0].enabled = false
            break
        case 1:
            unhideLetter("B")
            letterOutlet[1].enabled = false
            break
        case 2:
            unhideLetter("C")
            letterOutlet[2].enabled = false
            break
        case 3:
            unhideLetter("D")
            letterOutlet[3].enabled = false
            break
        case 4:
            unhideLetter("E")
            letterOutlet[4].enabled = false
            break
        case 5:
            unhideLetter("F")
            letterOutlet[5].enabled = false
            break
        case 6:
            unhideLetter("G")
            letterOutlet[6].enabled = false
            break
        case 7:
            unhideLetter("H")
            letterOutlet[7].enabled = false
            break
        case 8:
            unhideLetter("I")
            letterOutlet[8].enabled = false
            break
        case 9:
            unhideLetter("J")
            letterOutlet[9].enabled = false
            break
        case 10:
            unhideLetter("K")
            letterOutlet[10].enabled = false
            break
        case 11:
            unhideLetter("L")
            letterOutlet[11].enabled = false
            break
        case 12:
            unhideLetter("M")
            letterOutlet[12].enabled = false
            break
        case 13:
            unhideLetter("N")
            letterOutlet[13].enabled = false
            break
        case 14:
            unhideLetter("Ñ")
            letterOutlet[14].enabled = false
            break
        case 15:
            unhideLetter("O")
            letterOutlet[15].enabled = false
            break
        case 16:
            unhideLetter("P")
            letterOutlet[16].enabled = false
            break
        case 17:
            unhideLetter("Q")
            letterOutlet[17].enabled = false
            break
        case 18:
            unhideLetter("R")
            letterOutlet[18].enabled = false
            break
        case 19:
            unhideLetter("S")
            letterOutlet[19].enabled = false
            break
        case 20:
            unhideLetter("T")
            letterOutlet[20].enabled = false
            break
        case 21:
            unhideLetter("U")
            letterOutlet[21].enabled = false
            break
        case 22:
            unhideLetter("V")
            letterOutlet[22].enabled = false
            break
        case 23:
            unhideLetter("W")
            letterOutlet[23].enabled = false
            break
        case 24:
            unhideLetter("X")
            letterOutlet[24].enabled = false
            break
        case 25:
            unhideLetter("Y")
            letterOutlet[25].enabled = false
            break
        case 26:
            unhideLetter("Z")
            letterOutlet[26].enabled = false
            break
        default:
            print("Something else was pressed")
        }
    }
}