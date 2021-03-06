//
//  Build.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import FileKit

class BuildCommand: Command {
    
    let name = "build"
    let shortDescription = "Builds the current project"
    
    let clean = Flag("-c", "--clean")
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    func execute() throws {
        let spm = SPM()
        
        if clean.value {
            try spm.clean()
        }
        
        if watch.value {
            let watcher = try SourceWatcher() {
                do {
                    self.stdout <<< "[ice] rebuilding due to changes...".green
                    try spm.build(release: self.release.value)
                } catch {}
            }
            try watcher.go()
        } else {
            try spm.build(release: release.value)
        }
    }
    
}
