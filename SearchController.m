//
//  SearchController.m
//  Livit
//
//  Created by Nathan on 11/30/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import "SearchController.h"
#import "SearchCell.h"

#import "AppConstant.h"
#import <HNKGooglePlacesAutocomplete/HNKGooglePlacesAutocomplete.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "CLPlacemark+HNKAdditions.h"
#import "HousesController.h"

static NSString *const SearchResultsCellIdentifier = @"SearchResultsCellIdentifier";

@interface SearchController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) HNKGooglePlacesAutocompleteQuery *searchQuery;
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;



@end

@implementation SearchController
int sel;

-(void)actionNext{
    HousesController *hc = [[HousesController alloc]init];
    hc.event = self.event;
    [self.navigationController pushViewController:hc animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Choose a location";
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [HNKGooglePlacesAutocompleteQuery setupSharedQueryWithAPIKey:@"AIzaSyAfyalPB3lJGcL8JsgYvl-8WquhmRd4f0k"];
    self.searchQuery = [HNKGooglePlacesAutocompleteQuery sharedQuery];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellReuseIdentifier:@"searchCell"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(actionNext) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0,0,50,35);
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    sel = 30;
    [self.tableView setHidden:YES];
    
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchResults.count != 0){
    return self.searchResults.count;
    } else {
        if ([self.searchBar.text isEqualToString:@""]){
            return 0;
        } else {
        return 1;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.searchResults.count == 0)
    {
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        cell.locationLabel.text = self.searchBar.text;
        PFUser *user = [PFUser currentUser];
        cell.location = @{@"lat":[user[PF_USER_POSITION] objectForKey:@"lat"],@"long":[user[PF_USER_POSITION] objectForKey:@"long"],@"string":self.searchBar.text};

        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[user[PF_USER_POSITION] objectForKey:@"lat"] intValue], [[user[PF_USER_POSITION] objectForKey:@"long"] intValue]) addressDictionary:cell.location];
        [self addPlacemarkAnnotationToMap:placemark addressString:self.searchBar.text];
        [self recenterMapToPlacemark:placemark];
        cell.selectedView.image = [UIImage imageNamed:@"Ok-32"];
        return cell;
        
    } else {
        
    HNKGooglePlacesAutocompletePlace *thisPlace = self.searchResults[indexPath.row];
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    cell.locationLabel.text = thisPlace.name;
    
    HNKGooglePlacesAutocompletePlace *selectedPlace = self.searchResults[indexPath.row];
    
    [CLPlacemark hnk_placemarkFromGooglePlace: selectedPlace
                                       apiKey: self.searchQuery.apiKey
                                   completion:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                                       if (placemark) {
                                           NSNumber *lat = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
                                           NSNumber *lon = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];

                                          cell.location = @{@"lat":lat,@"long":lon,@"string":thisPlace.name};
                                           NSLog(@"%@",cell.location);
                                       }
                                   }];
            if (indexPath.row == sel){
            cell.selectedView.image = [UIImage imageNamed:@"Ok-32"];
            cell.userInteractionEnabled = NO;
                if (cell.location) {
                    self.event[@"Location"] = cell.location;
                    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[[cell.location objectForKey:@"lat"] doubleValue] longitude:[[cell.location objectForKey:@"long"] doubleValue]];
                    self.event[@"Geopoint"] = point;
                }
                if (cell.locationLabel.text) {
                    self.event[@"LocationString"] = cell.locationLabel.text;
                }
                
                
        } else {
            cell.selectedView.image = [UIImage imageNamed:@"Full Moon Filled-32"];
            cell.userInteractionEnabled = YES;
        }

        return cell;
    }
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
    HNKGooglePlacesAutocompletePlace *selectedPlace = self.searchResults[indexPath.row];
    
    [CLPlacemark hnk_placemarkFromGooglePlace: selectedPlace
                                       apiKey: self.searchQuery.apiKey
                                   completion:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                                       if (placemark) {
                                           //[self.tableView setHidden: YES];
                                           [self addPlacemarkAnnotationToMap:placemark addressString:addressString];
                                           [self recenterMapToPlacemark:placemark];
                                           [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                                       }
                                   }];
    SearchCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.searchBar.text = cell.locationLabel.text;
    sel = indexPath.row;
    [self.tableView setHidden:YES];
    [self.tableView reloadData];
    

}



#pragma mark - UISearchBar Delegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length > 0)
    {
        [self.tableView setHidden:NO];
        
        [self.searchQuery fetchPlacesForSearchQuery: searchText
                                         completion:^(NSArray *places, NSError *error) {
                                             if (error) {
                                                 NSLog(@"ERROR: %@", error);
                                                 [self handleSearchError:error];
                                             } else {
                                                 self.searchResults = places;
                                                 [self.tableView reloadData];
                                             }
                                         }];
    }
    else{
        
        [self.tableView setHidden:YES];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.tableView setHidden:YES];
}

#pragma mark - Helpers

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = placemark.location.coordinate;
    annotation.title = address;
    
    
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
    }
    else
    {
        pav.annotation = annotation;
    }
    
    return pav;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        
//        [GMSServices provideAPIKey:@"AIzaSyCMdkKlurqOvobVq2GHf5iXmTi4eliXVac"];
//        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(droppedAt.latitude, droppedAt.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
//            NSLog(@"reverse geocoding results:");
//            for(GMSAddress* addressObj in [response results])
//            {
//                NSLog(@"coordinate.latitude=%f", addressObj.coordinate.latitude);
//                NSLog(@"coordinate.longitude=%f", addressObj.coordinate.longitude);
//                NSLog(@"thoroughfare=%@", addressObj.thoroughfare);
//                NSLog(@"locality=%@", addressObj.locality);
//                NSLog(@"subLocality=%@", addressObj.subLocality);
//                NSLog(@"administrativeArea=%@", addressObj.administrativeArea);
//                NSLog(@"postalCode=%@", addressObj.postalCode);
//                NSLog(@"country=%@", addressObj.country);
//                NSLog(@"lines=%@", addressObj.lines);
//            }
//        }];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        
        //CLLocation *userLocation = self.mapView.userLocation.location;
        CLLocation *userLocation = [[CLLocation alloc]initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        [geocoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                return;
            }
            CLPlacemark *firstPlacemark = [placemarks firstObject];
            NSDictionary *addressDictionary = firstPlacemark.addressDictionary;
            NSString *street = addressDictionary[@"Street"];
            NSLog(@"%@",street);
            self.searchBar.text = street;
            [self searchBar:self.searchBar textDidChange:street];
        }];
        
    }
}

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region animated:YES];
}

- (void)handleSearchError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
