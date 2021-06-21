# zadanie-rekrutacyjne-zrobione

Komenda do deployu: sfdx force:source:deploy -p force-app/ -l RunLocalTests

Przypisanie domyślnego recordpagea nie przenosi się przy deploymencie, dlatego po deploymencie należy przejść poniższą ścieżkę: 
Setup > Lightning App Builder > Opportunity Record Page > Edit > Activation > Assign as Org Default > Next > Save
